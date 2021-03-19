import {APIGatewayEvent, Context} from "aws-lambda";
import {ResponseBody, SessionCookie} from "./types";
import {errorResponse, successResponse} from "./response";
import {v4 as uuidv4} from "uuid"
import {getSession, initTempSession} from "./redis/actions";
import redisClient from "./redis/client"
import {Status} from "../lib/result";
import {githubAuthorizeEndpoint} from "./endpoint";
import {parseCookie} from "./request";

const NODE_ENV: undefined | string = process.env.NODE_ENV

function resolveBackupReferer (): string {
  if (NODE_ENV) {
    switch(NODE_ENV) {
      case "development":
        return "http://localhost:8888"
      case "production":
        return "https://elm-exhibit.com"
      default:
        return "http://localhost:8888"
    }
  } else {
    return "http://localhost:8888"
  }
}

function resolveReferer (referer: undefined | string): string {
  if (referer) {
    return referer
  } else {
    return resolveBackupReferer()
  }
}

export async function handler(event: APIGatewayEvent, context: Context): Promise<ResponseBody> {
  const { referer, cookie } = event.headers
  const sessionId = uuidv4()
  const resolvedReferer: string = resolveReferer(referer)
  const authEndpoint = githubAuthorizeEndpoint(sessionId, resolvedReferer)
  if (redisClient.Status === Status.Ok) {
    const client = redisClient.data
    try {
      // check for cookie
      const cookieResult = parseCookie(cookie)
      if (cookieResult.Status === Status.Ok) {
        const cookie: SessionCookie = cookieResult.data
        const sessionResult = await getSession(cookie.session_id, client)
        if (sessionResult.Status === Status.Ok) {
          return successResponse({ tag: "SessionGranted", session: sessionResult.data})
        }
      }
      // save temporary session meta
      const tempSession = await initTempSession({ sessionId, referer: resolvedReferer }, client )

      if (tempSession && authEndpoint.Status === Status.Ok) {
        return successResponse({ tag: "Redirecting", location: authEndpoint.data.href })
      }
    } catch (e) {
      return errorResponse({ tag: "LoginFailed" })
    }
  }
  return errorResponse({ tag: "LoginFailed" })
}
