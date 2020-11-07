import { APIGatewayEvent, Context } from "aws-lambda";
import { ResponseBody } from "./types";
import { StatusCodes } from "http-status-codes";
import { URL } from "url";
import {errorResponse, successBody} from "./response";
import { v4 as uuidv4 } from "uuid"
import {initTempSession} from "./redis/actions";

const gitHubClientId: string | undefined = process.env.GITHUB_CLIENT_ID
const githubLoginEndpoint: URL = new URL("https://github.com/login/oauth/authorize")

export async function handler(event: APIGatewayEvent, context: Context): Promise<ResponseBody> {
  const { referer } = event.headers
  if (gitHubClientId) {
    const sessionId = uuidv4()
    const stateAsJSON = JSON.stringify({ tempSessionId: sessionId, referer: referer })
    const encodedState: string = new Buffer(stateAsJSON, "utf8").toString("base64")
    githubLoginEndpoint.searchParams.append("client_id", gitHubClientId)
    githubLoginEndpoint.searchParams.append("state", encodedState)
    // save temporary session meta
    const tempSession = await initTempSession({ sessionId, referer } )

    if (tempSession) {
      return successBody(StatusCodes.OK, { tag: "Redirecting", location: githubLoginEndpoint.href })
    }
  }
  return errorResponse({ tag: "LogInFailed" })
}
