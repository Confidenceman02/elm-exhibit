import {
  generateExpirableDBKey,
  generatePermanentDBKey,
  resolveExpiration,
} from "./common";
import {
  ExpirableDBTag,
  IPromisifiedRedis,
  PermanentDBTag,
  TempSession,
} from "./types";
import { GithubUserData } from "../types";
import {
  RedisHValue,
  UserSession,
  redisValueToUser,
  redisValueToUserSession,
  Table,
  User,
  UserSchemaKey,
} from "./schema";
import { Result, ResultType } from "../../lib/result";

// This will store the referer so that when the user approves the github app we can
// redirect them back to where they tried to login from. i.e. example page
export async function initTempSession(
  meta: TempSession,
  client: IPromisifiedRedis
): Promise<boolean> {
  const dbKey = generateExpirableDBKey(
    ExpirableDBTag.TempSession,
    meta.sessionId
  );
  const setSession = await client.HSETAsync(dbKey, "referer", meta.referer);
  client.EXPIRE(dbKey, resolveExpiration(ExpirableDBTag.TempSession));
  return !!setSession;
}

export async function initSession(
  sessionId: string,
  gitUser: GithubUserData,
  client: IPromisifiedRedis
): Promise<boolean> {
  const dbKey = generateExpirableDBKey(ExpirableDBTag.Session, sessionId);
  const setSession = await client.HSETAsync(
    dbKey,
    UserSchemaKey.username,
    gitUser.login,
    UserSchemaKey.userId,
    gitUser.id,
    UserSchemaKey.avatarUrl,
    gitUser.avatar_url,
    "sessionId",
    sessionId
  );
  client.EXPIRE(dbKey, resolveExpiration(ExpirableDBTag.Session));
  return !!setSession;
}

export async function getSession(
  sessionId: string,
  client: IPromisifiedRedis
): Promise<ResultType<UserSession>> {
  const key = generateExpirableDBKey(ExpirableDBTag.Session, sessionId);
  const redisUserSession: RedisHValue<UserSession> = await client.HGETALLAsync(
    key
  );
  const userSession: UserSession = redisValueToUserSession(redisUserSession);
  return Result<UserSession>().Ok(userSession);
}

export async function destroySession(
  sessionId: string,
  client: IPromisifiedRedis
): Promise<boolean> {
  const key = generateExpirableDBKey(ExpirableDBTag.Session, sessionId);
  const keysDestroyed: number = await client.DELAsync(key);
  return !!keysDestroyed;
}

export async function tempSessionExists(
  tempSesh: TempSession,
  client: IPromisifiedRedis
): Promise<boolean> {
  const dbKey = generateExpirableDBKey(
    ExpirableDBTag.TempSession,
    tempSesh.sessionId
  );
  const keyExists = await client.EXISTSAsync(dbKey);
  return !!keyExists;
}

export async function sessionExists(
  sessionId: string,
  client: IPromisifiedRedis
): Promise<boolean> {
  const dbKey = generateExpirableDBKey(ExpirableDBTag.Session, sessionId);
  const keyExists = await client.EXISTSAsync(dbKey);
  return !!keyExists;
}

export async function createUser(
  gitUser: GithubUserData,
  client: IPromisifiedRedis
): Promise<boolean> {
  const userReferenceKey = generatePermanentDBKey(
    PermanentDBTag.User,
    gitUser.id.toString()
  );
  const setUserReference = await client.ZADDAsync(
    Table.users,
    gitUser.id,
    userReferenceKey
  );
  const setUser = await client.HSETAsync(
    userReferenceKey,
    UserSchemaKey.username,
    gitUser.login,
    UserSchemaKey.userId,
    gitUser.id,
    UserSchemaKey.avatarUrl,
    gitUser.avatar_url
  );
  return !!setUserReference && !!setUser;
}

export async function userExists(
  gitUserId: number,
  client: IPromisifiedRedis
): Promise<boolean> {
  const userReferenceKey = generatePermanentDBKey(
    PermanentDBTag.User,
    gitUserId.toString()
  );
  const user = await client.EXISTSAsync(userReferenceKey);
  return !!user;
}

export async function getUser(
  gitUserId: number,
  client: IPromisifiedRedis
): Promise<ResultType<User>> {
  const userReferenceKey = generatePermanentDBKey(
    PermanentDBTag.User,
    gitUserId.toString()
  );
  const redisUser: RedisHValue<User> = await client.HGETALLAsync(
    userReferenceKey
  );
  const user = redisValueToUser(redisUser);
  return Result<User>().Ok(user);
}
