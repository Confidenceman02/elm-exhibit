import redisClientResult from "./client"
import {generateExpirableDBKey, generatePermanentDBKey, resolveExpiration} from "./common";
import {ExpirableDBTag, PermanentDBTag, TempSession} from "./types";
import {GithubUserData} from "../types";
import {Table, UserSchemaKey, User, RedisHValue, redisValueToUser} from "./schema";
import {Result, ResultType, Status} from '../../lib/result'

// This will store the referer so that when the user approves the github app we can
// redirect them back to where they tried to login from. i.e. example page
export async function initTempSession(meta: TempSession): Promise<boolean> {
  if (redisClientResult.Status === Status.Ok) {
    const client = redisClientResult.data
    const dbKey = generateExpirableDBKey(ExpirableDBTag.TempSession, meta.sessionId)
    const setSession = await client.HSETAsync(dbKey, "referer", meta.referer )
    client.EXPIRE(dbKey, resolveExpiration(ExpirableDBTag.TempSession))
    return !!setSession
  }
  return false
}

export async function initSession(sessionId: string, gitUser: GithubUserData): Promise<boolean> {
  if (redisClientResult.Status === Status.Ok) {
    const client = redisClientResult.data
    const dbKey = generateExpirableDBKey(ExpirableDBTag.Session, sessionId)
    const setSession = await client.HSETAsync(dbKey, UserSchemaKey.username, gitUser.login, UserSchemaKey.avatarUrl, gitUser.avatar_url)
    client.EXPIRE(dbKey, resolveExpiration(ExpirableDBTag.Session))
    return !!setSession
  }
  return false
}

export async function tempSessionExists(tempSesh: TempSession): Promise<boolean> {
  if (redisClientResult.Status == Status.Ok) {
    const client = redisClientResult.data
    const dbKey = generateExpirableDBKey(ExpirableDBTag.TempSession, tempSesh.sessionId)
    const keyExists = await client.EXISTSAsync(dbKey)
    return !!keyExists
  }
  return false
}

export async function createUser(gitUser: GithubUserData): Promise<boolean> {
  if (redisClientResult.Status === Status.Ok) {
    const client = redisClientResult.data
    const userReferenceKey = generatePermanentDBKey(PermanentDBTag.User, gitUser.id.toString())
    const setUserReference = await client.ZADDAsync(Table.users, gitUser.id, userReferenceKey)
    const setUser = await client.HSETAsync(userReferenceKey, UserSchemaKey.username, gitUser.login, UserSchemaKey.userId, gitUser.id, UserSchemaKey.avatarUrl, gitUser.avatar_url)
    return (!!setUserReference && !!setUser)
  }
  return false
}

export async function getUser(gitUserId: number): Promise<ResultType<User>> {
  if (redisClientResult.Status === Status.Ok) {
    const client = redisClientResult.data
    const userReferenceKey = generatePermanentDBKey(PermanentDBTag.User, gitUserId.toString())
    const redisUser: RedisHValue<User> = await client.HGETALLAsync(userReferenceKey)
    const user = redisValueToUser(redisUser)
    console.log('USER', user)
    return Result<User>().Ok(user)
  }
  return Result().Err
}