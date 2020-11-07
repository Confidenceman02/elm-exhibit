import {APIGatewayEvent, Context} from "aws-lambda";
import {ResponseBody} from "./types";
import {errorResponse, noIdea, successBody} from "./response";
import {StatusCodes} from "http-status-codes";

export async function handler(event: APIGatewayEvent, context: Context): Promise<ResponseBody> {
  const params = event.queryStringParameters

  if (!params) {
    return errorResponse(noIdea)
  }

  if (params.code && params.state) {
  //  exchange code for access token
  //  return credentials such as name and id
    return successBody(StatusCodes.OK, { tag: "SessionGranted" })
  }
  return errorResponse(noIdea)
}
