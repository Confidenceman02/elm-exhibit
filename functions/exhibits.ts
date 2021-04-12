import { APIGatewayEvent, Context } from "aws-lambda";
import { ResponseBody } from "./types";
import redisClient from "./redis/client";
import { Status } from "../lib/result";
import { errorResponse, noIdea } from "./response";

export async function handler(
  event: APIGatewayEvent,
  context: Context
): Promise<ResponseBody> {
  const params = event.queryStringParameters;
  if (!params || !params.author) {
    return errorResponse(noIdea);
  }
  const author: string = params.author;
  if (redisClient.Status === Status.Err) {
    return errorResponse(noIdea);
  }
  return errorResponse(noIdea);
}
