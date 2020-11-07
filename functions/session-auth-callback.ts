import {APIGatewayEvent, Context} from "aws-lambda";
import {ResponseBody, ResultTuple, TempSession} from "./types";
import {errorResponse, noIdea, successBody} from "./response";
import {StatusCodes} from "http-status-codes";
import fetch from "node-fetch"
import {tempSessionExists} from "./redis/actions";
import {githubLoginEndpoint} from "./endpoint";


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
        const endPointResult: ResultTuple<URL> = githubLoginEndpoint(params.code)
      }
      return successBody(StatusCodes.OK, { tag: "SessionGranted" })
    } catch (e) {
      return errorResponse(noIdea)
    }
  }
  return errorResponse(noIdea)
}
