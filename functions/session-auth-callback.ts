import {APIGatewayEvent, Context} from "aws-lambda";
import {GithubUserData, ResponseBody, TempSession} from "./types";
import {ResultType, Status} from "../lib/result";
import {errorResponse, noIdea} from "./response";
import {initSession, tempSessionExists} from "./redis/actions";
import {githubLoginEndpoint, githubUserEndpoint} from "./endpoint";
import fetch from "node-fetch";
import {acceptJson, withAuth} from "./headers";

export async function handler(event: APIGatewayEvent, context: Context): Promise<ResponseBody> {
  const params = event.queryStringParameters

  if (!params) {
    return errorResponse(noIdea)
  }

  if (params.code && params.state) {
    const decodedState: string = Buffer.from(params.state, "base64").toString("utf8")

    try {
      const stateParamAsObject: TempSession = JSON.parse(decodedState)
      // make sure a temp session exists.
      const sessionExists = await tempSessionExists(stateParamAsObject)
      const loginEndPoint: ResultType<URL> = githubLoginEndpoint(params.code)
      if (sessionExists && loginEndPoint.Status === Status.Ok) {
        const response = await fetch(loginEndPoint.data.href, { method: "POST", headers: { ...acceptJson } })
        const responseData = await response.json()
        //  get user github info
        const githubUserResponse = await fetch(githubUserEndpoint().href, { headers: { ...acceptJson, ...withAuth(responseData.access_token) } })
        const parsedGithubUserResponse = await githubUserResponse.json()
        console.log(parsedGithubUserResponse)
      //  save permanent session
      }
      return errorResponse({ tag: "LogInFailed" })
    } catch (e) {
      console.log(e)
      return errorResponse(noIdea)
    }
  }
  return errorResponse(noIdea)
}