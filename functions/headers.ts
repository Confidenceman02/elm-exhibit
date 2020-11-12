import {UserSession} from "./types";

export const jsonHeaders = {
  "Content-Type": "application/json"
}

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
    "Set-Cookie": `session_id=${session.sessionId}; Secure; HttpOnly`
  }
}