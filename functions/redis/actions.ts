import redisClientResult from "./client"
import {generateExpirableDBKey, generatePermanentDBKey, resolveExpiration} from "./common";
import {ExpirableDBTag, PermanentDBTag, TempSessionMeta} from "./types";
import {GithubUserData, TempSession} from "../types";
import {Table, UserSchema} from "./schema";
import {Status} from '../../lib/result'

// This will store the referer so that when the user approves the github app we can
// redirect them back to where they tried to login from. i.e. example page
export async function initTempSession(meta: TempSessionMeta): Promise<boolean> {
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
    const setSession = await client.HSETAsync(dbKey, UserSchema.userName, gitUser.login, UserSchema.avatarUrl, gitUser.avatar_url)
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
    const setUser = await client.HSETAsync(userReferenceKey, UserSchema.userName, gitUser.login, UserSchema.userId, gitUser.id, UserSchema.avatarUrl, gitUser.avatar_url)
    return (!!setUserReference && !!setUser)
  }
  return false
}