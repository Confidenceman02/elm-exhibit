import { StatusCodes } from "http-status-codes";
import { APIGatewayEvent, Context } from "aws-lambda";
import { errorResponse, noIdea } from "./response";
import { ResponseBody } from "./types";

export async function handler(
  event: APIGatewayEvent,
  context: Context
): Promise<ResponseBody> {
  const params = event.queryStringParameters;

  if (!params) {
    return errorResponse(noIdea);
  }

  if (params.author && params.package && params.example) {
    return {
      statusCode: StatusCodes.OK,
      body: "WORKED",
      headers: {
        "Content-Type": "text/javascript",
      },
    };
  }
  return errorResponse(noIdea);
}
