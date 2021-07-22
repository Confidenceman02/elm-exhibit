import { APIGatewayEvent, Context } from "aws-lambda";
import { ElmLangPackage, ResponseBody } from "./types";
import redisClient from "./redis/client";
import { Status } from "../lib/result";
import { errorResponse, noIdea, successResponse } from "./response";
import { getExhibitsByUserId, getUserIdByUsername } from "./redis/actions";
import { elmLangPackagesToAuthor } from "./common";
import { getElmPackages } from "./api";

export async function handler(
  event: APIGatewayEvent,
  _context: Context
): Promise<ResponseBody> {
  const params = event.queryStringParameters;
  if (!params || !params.author) {
    return errorResponse({ tag: "MissingAuthorParam" });
  }
  const author: string = params.author;
  if (redisClient.Status === Status.Err) {
    return errorResponse(noIdea);
  }
  const client = redisClient.data;
  const userIdResult = await getUserIdByUsername(author, client);
  // Author isn't registered with elm-exhibit but maybe they are elm package authors?
  if (userIdResult.Status === Status.Err) {
    const elmPackagesResult = await getElmPackages(client);
    if (elmPackagesResult.Status === Status.Ok) {
      const authorPackages: ElmLangPackage[] = elmLangPackagesToAuthor(
        author,
        elmPackagesResult.data
      );

      if (authorPackages.length === 0)
        // not an elm package author
        return errorResponse({ tag: "AuthorNotFound" });
      return errorResponse({
        tag: "AuthorNotFoundHasElmLangPackages",
        packages: authorPackages,
      });
    }
    return errorResponse(noIdea);
  }

  const userExhibits = await getExhibitsByUserId(userIdResult.data, client);

  if (userExhibits.Status === Status.Err) return errorResponse(noIdea);

  return successResponse({
    tag: "AuthorExhibitsFetched",
    exhibits: userExhibits.data,
  });
}
