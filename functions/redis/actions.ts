import {
  generateElmPackagesCacheKey,
  generateExhibitKey,
  generateSessionKey,
  generateTempSessionKey,
  generateUserKey,
  resolveExpiration,
} from "./common";
import {
  ExpirableDBKey,
  IPromisifiedRedis,
  IPromisifiedRedisMulti,
  TempSession,
} from "./types";
import { ElmLangPackage, GithubLoginData, GithubUserData } from "../types";
import {
  redisElmPackagesCacheToElmLangPackages,
  RedisHValue,
  RedisReturnType,
  redisUserIdToUserId,
  redisUserSessionUserSession,
  redisUserToUser,
  redisValueToValueResult,
  Table,
  User,
  UserSchemaKey,
  UserSession,
} from "./schema";
import { Result, ResultType, Status } from "../../lib/result";
import { redisClientMulti } from "./client";

// This will store the referer so that when the user approves the github app we can
// redirect them back to where they tried to login from. i.e. example page
export async function initTempSession(
  meta: TempSession,
  client: IPromisifiedRedis
): Promise<boolean> {
  const clientMulti: IPromisifiedRedisMulti = redisClientMulti(client);
  const dbKey = generateTempSessionKey(meta.sessionId);

  clientMulti.HSET(dbKey, "referer", meta.referer);
  clientMulti.EXPIRE(dbKey, resolveExpiration(ExpirableDBKey.TempSession));
  const multiReturn: number[] = await clientMulti.EXECAsync();

  return multiReturn.every(Boolean);
}

export async function initSession(
  sessionId: string,
  gitUser: GithubUserData,
  client: IPromisifiedRedis
): Promise<boolean> {
  const dbKey = generateSessionKey(sessionId);
  const clientMulti: IPromisifiedRedisMulti = redisClientMulti(client);

  clientMulti.HSET(
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
  clientMulti.EXPIRE(dbKey, resolveExpiration(ExpirableDBKey.Session));
  const multiReturn: number[] = await clientMulti.EXECAsync();

  return multiReturn.every(Boolean);
}

export async function getSession(
  sessionId: string,
  client: IPromisifiedRedis
): Promise<ResultType<UserSession>> {
  const key = generateSessionKey(sessionId);
  const redisUserSession: RedisHValue<UserSession> = await client.HGETALLAsync(
    key
  );
  const userSession: ResultType<UserSession> =
    redisUserSessionUserSession(redisUserSession);
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
  const clientMulti = redisClientMulti(client);

  // user reference stores a git username and a pointer to the user table. Handy for complex queries.
  clientMulti.ZADD(Table.users, gitUser.id, gitUser.login);
  clientMulti.HSET(
    userReferenceKey,
    UserSchemaKey.username,
    gitUser.login,
    UserSchemaKey.userId,
    gitUser.id.toString(),
    UserSchemaKey.avatarUrl,
    gitUser.avatar_url,
    UserSchemaKey.accessToken,
    loginData.access_token
  );
  const multiReturn: number[] = await clientMulti.EXECAsync();

  return multiReturn.every(Boolean);
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
  const redisUser: RedisReturnType<RedisHValue<User>> =
    await client.HGETALLAsync(userReferenceKey);
  return redisUserToUser(redisUser);
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
  const redisUserName: RedisReturnType<string[]> =
    await client.ZRANGEBYSCOREAsync(Table.users, userId, userId);
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
  const exhibitReferences: RedisReturnType<string[]> =
    await client.ZRANGEBYSCOREAsync(Table.exhibits, userId, userId);
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

export async function getExhibitsByUserId(
  userId: number,
  client: IPromisifiedRedis
): Promise<ResultType<[]>> {
  // TODO: Create data structure for exhibits
  return Result<[]>().Ok([]);
}

export async function setElmPackagesCache(
  packages: ElmLangPackage[],
  client: IPromisifiedRedis
): Promise<boolean> {
  const clientMulti = redisClientMulti(client);
  const dbKey = generateElmPackagesCacheKey();
  for (const pkg of packages) {
    clientMulti.RPUSH(dbKey, pkg.name);
  }
  const multiReturn: number[] = await clientMulti.EXECAsync();
  client.EXPIREAsync(dbKey, resolveExpiration(ExpirableDBKey.ElmPackages));
  return multiReturn[multiReturn.length - 1] === packages.length;
}

export async function getElmPackagesCache(
  client: IPromisifiedRedis
): Promise<ResultType<ElmLangPackage[]>> {
  const dbKey = generateElmPackagesCacheKey();
  const cacheExists: number = await client.EXISTSAsync(dbKey);
  if (cacheExists === 0) return Result().Err;
  const elmPackages: RedisReturnType<string[]> = await client.LRANGEAsync(
    dbKey,
    0,
    -1
  );
  return redisElmPackagesCacheToElmLangPackages(elmPackages);
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
