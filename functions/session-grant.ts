import {APIGatewayEvent, Context} from "aws-lambda";
import {ResponseBody} from "./types";
import {errorResponse, successResponse} from "./response";
import {v4 as uuidv4} from "uuid"
import {initTempSession} from "./redis/actions";
import redisClient from "./redis/client"
import {Status} from "../lib/result";
import {githubAuthorizeEndpoint} from "./endpoint";

export async function handler(event: APIGatewayEvent, context: Context): Promise<ResponseBody> {
  const { referer } = event.headers
  const sessionId = uuidv4()
  const authEndpoint = githubAuthorizeEndpoint(sessionId, referer)
  if (redisClient.Status === Status.Ok && authEndpoint.Status === Status.Ok) {
    const client = redisClient.data
    // save temporary session meta
    const tempSession = await initTempSession({ sessionId, referer }, client )

    if (tempSession) {
      return successResponse({ tag: "Redirecting", location: authEndpoint.data.href })
    }
  }
  return errorResponse({ tag: "LogInFailed" })
}
