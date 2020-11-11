import client from "./client"
import {generateDBKey, resolveExpiration} from "./common";
import {DBTag, TempSessionMeta} from "./types";
import {GithubUserData, TempSession} from "../types";

// This will store the referer so that when the user approves the github app we can
// redirect them back to where they tried to login from. i.e. example page
export async function initTempSession(meta: TempSessionMeta): Promise<boolean> {
  const dbKey = generateDBKey(DBTag.TempSession, meta.sessionId)
  const setSession = await client.HSETAsync(dbKey, "referer", meta.referer )
  client.EXPIRE(dbKey, resolveExpiration(DBTag.TempSession))

  return !!setSession
}

export async function initSession(sessionId: string, gitUser: GithubUserData): Promise<boolean> {
  const dbKey = generateDBKey(DBTag.Session, sessionId)
  const setSession = await client.HSETAsync(dbKey, "username", gitUser.login, "avatarUrl", gitUser.avatar_url)
  client.EXPIRE(dbKey, resolveExpiration(DBTag.Session))

  return !!setSession
}

export async function getTempSession(tempSesh: TempSession) {
  // This generated key should be an exact match to the initially generated key
  const dbKey = generateDBKey(DBTag.TempSession, tempSesh.sessionId)
  const tempSessionData = await client.HGETALLAsync(dbKey)
  return tempSessionData
}

export async function tempSessionExists(tempSesh: TempSession): Promise<boolean> {
  const dbKey = generateDBKey(DBTag.TempSession, tempSesh.sessionId)
  const keyExists = await client.EXISTSAsync(dbKey)
  return !!keyExists
}