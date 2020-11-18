import { APIGatewayEvent, Context } from "aws-lambda";
import { ResponseBody } from "./types";
import { URL } from "url";
import {errorResponse, successResponse} from "./response";
import { v4 as uuidv4 } from "uuid"
import {initTempSession} from "./redis/actions";
import redisClient from "./redis/client"

const gitHubClientId: string | undefined = process.env.GITHUB_CLIENT_ID

export async function handler(event: APIGatewayEvent, context: Context): Promise<ResponseBody> {
  const { referer } = event.headers
  if (gitHubClientId) {
    const sessionId = uuidv4()
    const stateAsJSON: string = JSON.stringify({ sessionId: sessionId, referer: referer })
    const encodedState: string = Buffer.from(stateAsJSON, "utf8").toString("base64")
    githubAuthorizeEndpoint.searchParams.append("client_id", gitHubClientId)
    githubAuthorizeEndpoint.searchParams.append("state", encodedState)
    // save temporary session meta
    const tempSession = await initTempSession({ sessionId, referer } )

    if (tempSession) {
      return successResponse({ tag: "Redirecting", location: githubAuthorizeEndpoint.href })
    }
  }
  return errorResponse({ tag: "LogInFailed" })
}
