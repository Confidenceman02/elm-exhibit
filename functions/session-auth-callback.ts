import {APIGatewayEvent, Context} from "aws-lambda";
import {ResponseBody,TempSession} from "./types";
import {ResultType, Status} from "../lib/result";
import {errorResponse, noIdea} from "./response";
import {tempSessionExists} from "./redis/actions";
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
      const stateAsObject: TempSession = JSON.parse(decodedState)
      // We make sure a temp session exists.
      const sessionExists = await tempSessionExists(stateAsObject)
      if (sessionExists) {
        //  exchange code for access token
        const endPointResult: ResultType<URL> = githubLoginEndpoint(params.code)
      }
      return errorResponse({ tag: "LogInFailed" })
    } catch (e) {
      return errorResponse(noIdea)
    }
  }
  return errorResponse(noIdea)
}
