import {APIGatewayEvent, Context} from "aws-lambda";
import {ResponseBody} from "./types";
import {errorResponse, noIdea} from "./common";
import {StatusCodes} from "http-status-codes";

export async function handler(event: APIGatewayEvent, context: Context): Promise<ResponseBody> {
  const params = event.queryStringParameters

  if (!params) {
    return errorResponse(StatusCodes.BAD_REQUEST, noIdea )
  }

  if (params.code && params.state) {
  //  exchange code for access token
    return {
      statusCode: StatusCodes.OK,
      body: "EXCHANGED FOR ACCESS TOKEN",
      headers: {
        "Content-Type": "text/javascript"
      }
    }
  }
  return {
    statusCode: StatusCodes.INTERNAL_SERVER_ERROR,
    body: "NOVALUESON",
    headers: {
      "Content-Type": "application/json"
    }
  }
}
