import {UserSession} from "./redis/schema";

export const jsonHeaders = {
  "Content-Type": "application/json"
}

export const sessionIdCookieKey = "session_id"

export const acceptJson = {
  "Accept": "application/json"
}

export function withAuth(oauthToken: string) {
  return {
    "Authorization": `token ${oauthToken}`
  }
}

export function withSessionCookie(session: UserSession) {
  return {
    // TODO: add secure only for production env
    "Set-Cookie": `${sessionIdCookieKey}=${session.sessionId}; HttpOnly`
  }
}