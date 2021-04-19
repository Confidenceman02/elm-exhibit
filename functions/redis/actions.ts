import {
  generateExhibitKey,
  generateSessionKey,
  generateTempSessionKey,
  generateUserKey,
  resolveExpiration,
} from "./common";
import { ExpirableDBTag, IPromisifiedRedis, TempSession } from "./types";
import { GithubLoginData, GithubUserData } from "../types";
import {
  RedisHValue,
  RedisReturnType,
  redisReturnValueToUser,
  redisUserIdToUserId,
  redisUserSessionUserSession,
  redisValueToValueResult,
  Table,
  User,
  UserSchemaKey,
  UserSession,
} from "./schema";
import { Result, ResultType, Status } from "../../lib/result";

// This will store the referer so that when the user approves the github app we can
// redirect them back to where they tried to login from. i.e. example page
export async function initTempSession(
  meta: TempSession,
  client: IPromisifiedRedis
): Promise<boolean> {
  const dbKey = generateTempSessionKey(meta.sessionId);
  // returns the number of fields changed, should always be > 0
  const tempSessionSet: number = client.HSETAsync(
    dbKey,
    "referer",
    meta.referer
  );
  client.EXPIRE(dbKey, resolveExpiration(ExpirableDBTag.TempSession));
  return !!tempSessionSet;
}

export async function initSession(
  sessionId: string,
  gitUser: GithubUserData,
  client: IPromisifiedRedis
): Promise<boolean> {
  const dbKey = generateSessionKey(sessionId);
  const sessionInitiated: number = client.HSETAsync(
    dbKey,
    UserSchemaKey.username,
    gitUser.login,
    UserSchemaKey.userId,
    gitUser.id.toString(),
    UserSchemaKey.avatarUrl,
    gitUser.avatar_url,
    "sessionId",
    sessionId
  );
  client.EXPIRE(dbKey, resolveExpiration(ExpirableDBTag.Session));
  return !!sessionInitiated;
}

export async function getSession(
  sessionId: string,
  client: IPromisifiedRedis
): Promise<ResultType<UserSession>> {
  const key = generateSessionKey(sessionId);
  const redisUserSession: RedisHValue<UserSession> = await client.HGETALLAsync(
    key
  );
  const userSession: ResultType<UserSession> = redisUserSessionUserSession(
    redisUserSession
  );
  return userSession;
}

export async function destroySession(
  sessionId: string,
  client: IPromisifiedRedis
): Promise<boolean> {
  const key = generateSessionKey(sessionId);
  const keysDestroyed: number = await client.DELAsync(key);
  return !!keysDestroyed;
}

export async function tempSessionExists(
  tempSesh: TempSession,
  client: IPromisifiedRedis
): Promise<boolean> {
  const dbKey = generateTempSessionKey(tempSesh.sessionId);
  const exists: number = await client.EXISTSAsync(dbKey);
  return !!exists;
}

export async function sessionExists(
  sessionId: string,
  client: IPromisifiedRedis
): Promise<boolean> {
  const dbKey = generateSessionKey(sessionId);
  const exists: number = await client.EXISTSAsync(dbKey);
  return !!exists;
}

export async function createUser(
  gitUser: GithubUserData,
  loginData: GithubLoginData,
  client: IPromisifiedRedis
): Promise<boolean> {
  const userReferenceKey = generateUserKey(gitUser.id);
  // user reference stores a git username and a pointer to the user table. Handy for complex queries.
  const setUserNameReference = await client.ZADDAsync(
    Table.users,
    gitUser.id,
    gitUser.login
  );
  const setUser = await client.HSETAsync(
    userReferenceKey,
    UserSchemaKey.username,
    gitUser.login,
    UserSchemaKey.userId,
    gitUser.id,
    UserSchemaKey.avatarUrl,
    gitUser.avatar_url,
    UserSchemaKey.accessToken,
    loginData.access_token
  );
  return !!setUserNameReference && !!setUser;
}

export async function userExists(
  gitUserId: number,
  client: IPromisifiedRedis
): Promise<boolean> {
  const userReferenceKey = generateUserKey(gitUserId);
  const user: number = await client.EXISTSAsync(userReferenceKey);
  return !!user;
}

export async function getUser(
  gitUserId: number,
  client: IPromisifiedRedis
): Promise<ResultType<User>> {
  const userReferenceKey = generateUserKey(gitUserId);
  const redisUser: RedisReturnType<
    RedisHValue<User>
  > = await client.HGETALLAsync(userReferenceKey);
  return redisReturnValueToUser(redisUser);
}

export async function getUserIdByUsername(
  username: string,
  client: IPromisifiedRedis
): Promise<ResultType<number>> {
  const redisUserId: RedisReturnType<string> = await client.ZSCOREAsync(
    Table.users,
    username
  );

  return redisUserIdToUserId(redisUserId);
}

export async function getUsernameByUserId(
  userId: number,
  client: IPromisifiedRedis
): Promise<ResultType<string>> {
  const redisUserName: RedisReturnType<
    string[]
  > = await client.ZRANGEBYSCOREAsync(Table.users, userId, userId);
  const resolvedResult = redisValueToValueResult<string[]>(redisUserName);
  if (resolvedResult.Status == Status.Err) return resolvedResult;
  if (resolvedResult.data.length === 0) return Result().Err;
  const [username] = resolvedResult.data;
  return Result<string>().Ok(username);
}

export async function getExhibitReferencesByUserId(
  userId: number,
  client: IPromisifiedRedis
): Promise<ResultType<string[]>> {
  const exhibitReferences: RedisReturnType<
    string[]
  > = await client.ZRANGEBYSCOREAsync(Table.exhibits, userId, userId);
  return redisValueToValueResult<string[]>(exhibitReferences);
}

export async function createExhibitReference(
  userId: number,
  exhibitName: string,
  client: IPromisifiedRedis
): Promise<boolean> {
  const usernameResult = await getUsernameByUserId(userId, client);
  if (usernameResult.Status === Status.Err) return false;
  const exhibitReference = generateExhibitKey(usernameResult.data, exhibitName);
  const setReference = await client.ZADDAsync(
    Table.exhibits,
    userId,
    exhibitReference
  );
  return !!setReference;
}

export async function updateUserAccessToken(
  userId: number,
  access_token: string,
  client: IPromisifiedRedis
): Promise<boolean> {
  const userDbKey = generateUserKey(userId);
  const validUser = await userExists(userId, client);
  if (!validUser) return false;
  const userAccessTokenUpdated: boolean = client.HSET(
    userDbKey,
    UserSchemaKey.accessToken,
    access_token
  );
  return userAccessTokenUpdated;
}

// export async function getExhibitsByUsername(
//   username: string,
//   client: IPromisifiedRedis
// ): ResultType<Exhibit[]> {
//   const redisUserId: ResultType<number> = await getUserIdByUsername(
//     username,
//     client
//   );
//   if (redisUserId.Status === Status.Err) return Result<null>().Err;
//   const key = generatePermanentDBKey(
//     PermanentDBTag.Exhibit,
//     redisUserId.data.toString()
//   );
// }
