import { APIGatewayEvent, Context } from "aws-lambda";
import { ResponseBody } from "./types";
import redisClient from "./redis/client";
import { Status } from "../lib/result";
import { errorResponse, noIdea } from "./response";
import { getExhibitsByUserId, getUserIdByUsername } from "./redis/actions";

export async function handler(
  event: APIGatewayEvent,
  context: Context
): Promise<ResponseBody> {
  const params = event.queryStringParameters;
  if (!params || !params.author) {
    return errorResponse({ tag: "MissingAuthor" });
  }
  const author: string = params.author;
  if (redisClient.Status === Status.Err) {
    return errorResponse(noIdea);
  }
  const userIdResult = await getUserIdByUsername(author, redisClient.data);
  if (userIdResult.Status === Status.Err)
    return errorResponse({ tag: "AuthorNotFound" });
  // TODO: get user exhibits

  const userExhibits = await getExhibitsByUserId(
    userIdResult.data,
    redisClient.data
  );

  if (userExhibits.Status === Status.Err) return errorResponse(noIdea);

  return errorResponse(noIdea);
}
