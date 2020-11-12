import client from "./client"
import {generateExpirableDBKey, generatePermanentDBKey, resolveExpiration} from "./common";
import {ExpirableDBTag, PermanentDBTag, TempSessionMeta} from "./types";
import {GithubUserData, TempSession} from "../types";
import {Table, UserSchema} from "./schema";

// This will store the referer so that when the user approves the github app we can
// redirect them back to where they tried to login from. i.e. example page
export async function initTempSession(meta: TempSessionMeta): Promise<boolean> {
  const dbKey = generateExpirableDBKey(ExpirableDBTag.TempSession, meta.sessionId)
  const setSession = await client.HSETAsync(dbKey, "referer", meta.referer )
  client.EXPIRE(dbKey, resolveExpiration(ExpirableDBTag.TempSession))

  return !!setSession
}

export async function initSession(sessionId: string, gitUser: GithubUserData): Promise<boolean> {
  const dbKey = generateExpirableDBKey(ExpirableDBTag.Session, sessionId)
  const setSession = await client.HSETAsync(dbKey, UserSchema.userName, gitUser.login, UserSchema.avatarUrl, gitUser.avatar_url)
  client.EXPIRE(dbKey, resolveExpiration(ExpirableDBTag.Session))

  return !!setSession
}

export async function getTempSession(tempSesh: TempSession) {
  // This generated key should be an exact match to the initially generated key
  const dbKey = generateExpirableDBKey(ExpirableDBTag.TempSession, tempSesh.sessionId)
  const tempSessionData = await client.HGETALLAsync(dbKey)
  return tempSessionData
}

export async function tempSessionExists(tempSesh: TempSession): Promise<boolean> {
  const dbKey = generateExpirableDBKey(ExpirableDBTag.TempSession, tempSesh.sessionId)
  const keyExists = await client.EXISTSAsync(dbKey)
  return !!keyExists
}

export async function createUser(gitUser: GithubUserData): Promise<boolean> {
  const userReferenceKey = generatePermanentDBKey(PermanentDBTag.User, gitUser.id.toString())
  const setUserReference = await client.ZADDAsync(Table.users, gitUser.id, userReferenceKey)
  const setUser = await client.HSETAsync(userReferenceKey, UserSchema.userName, gitUser.login, UserSchema.userId, gitUser.id, UserSchema.avatarUrl, gitUser.avatar_url)
  return (!!setUserReference && !!setUser)
}