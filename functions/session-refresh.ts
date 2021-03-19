import { APIGatewayEvent, Context } from "aws-lambda";
import { ResponseBody } from "./types";
import {errorResponse, successResponse} from "./response";
import {getSession} from "./redis/actions";
import redisClient from "./redis/client"
import {Status} from "../lib/result";
import {parseCookie} from "./request";

// session refresh only works if there is a cookie.
// The page will try refresh the session automatically and this endpoint is not reached
// by user action.
export async function handler(event: APIGatewayEvent, context: Context): Promise<ResponseBody> {
  const { cookie } = event.headers
  const cookieResult = parseCookie(cookie)

  if (cookieResult.Status === Status.Ok) {
    if (redisClient.Status === Status.Ok) {
      const sessionResult = await getSession(cookieResult.data.session_id, redisClient.data)
      if (sessionResult.Status === Status.Ok) {
        return successResponse({ tag: "SessionRefreshed", session: sessionResult.data })
      }
      return errorResponse({ tag: "RefreshFailed"})
    }
    return errorResponse({ tag: "LoginFailed" })
  }
  return errorResponse({ tag: "RefreshFailed"})
}