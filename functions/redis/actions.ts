import client from "./client"
import {generateDBKey} from "./common";
import {DBTag} from "./types";

type TempSessionMeta =
  {
    sessionId: string,
    referer: string
  }
// This will store the referer so that when the user approves the github app we can
// redirect them back to where they tried to login from. i.e. example page
export async function initTempSession(meta: TempSessionMeta): Promise<boolean> {
  const dbKey = generateDBKey(DBTag.TempSession, meta.sessionId)
  const setSession = await client.HSETAsync(dbKey, "referer", meta.referer )
  client.EXPIRE(dbKey, 10600)

  return !!setSession
}