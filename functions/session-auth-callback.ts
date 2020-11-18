import {APIGatewayEvent, Context} from "aws-lambda";
import {GithubUserData, ResponseBody} from "./types";
import {TempSession} from "./redis/types";
import {ResultType, Status} from "../lib/result";
import {errorResponse, noIdea, successResponse} from "./response";
import {createUser, getSession, initSession, tempSessionExists} from "./redis/actions";
import {githubLoginEndpoint, githubUserEndpoint} from "./endpoint";
import fetch from "node-fetch";
import {acceptJson, withAuth} from "./headers";
import {UserSession} from "./redis/schema";
import redisClient from "./redis/client";

export async function handler(event: APIGatewayEvent, context: Context): Promise<ResponseBody> {
  const params = event.queryStringParameters

  if (!params || !params.code || !params.state || redisClient.Status === Status.Err) {
    return errorResponse(noIdea)
  }

  const client = redisClient.data

  const decodedState: string = Buffer.from(params.state, "base64").toString("utf8")

  try {
    const stateParamAsObject: TempSession = JSON.parse(decodedState)
    const sessionId = stateParamAsObject.sessionId
    // make sure a temp session exists.
    const tmpSessionExists = await tempSessionExists(stateParamAsObject, client)
    const loginEndPoint: ResultType<URL> = githubLoginEndpoint(params.code)
    if (tmpSessionExists && loginEndPoint.Status === Status.Ok) {
      const response = await fetch(loginEndPoint.data.href, { method: "POST", headers: { ...acceptJson } })
      const responseData = await response.json()
      //  get user github info
      const githubUserResponse = await fetch(githubUserEndpoint().href, { headers: { ...acceptJson, ...withAuth(responseData.access_token) } })
      const parsedGithubUserResponse: GithubUserData = await githubUserResponse.json()
      const initiatedSession: boolean = await initSession(sessionId, parsedGithubUserResponse, client)
      if (initiatedSession) {
        // TODO: check for existing user based on id before creating a user
        const createdUser: boolean = await createUser(parsedGithubUserResponse, client)
        const session: ResultType<UserSession> = await getSession(sessionId, client)
        // send success response
        return successResponse({ tag: "SessionGranted", session: session.data})
      }
      return errorResponse({ tag: "LogInFailed" })
    }
    return errorResponse({ tag: "LogInFailed" })
  } catch (e) {
    console.log(e)
    return errorResponse(noIdea)
  }
}