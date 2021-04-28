import { APIGatewayEvent, Context } from "aws-lambda";
import { ElmLangPackage, ResponseBody } from "./types";
import redisClient from "./redis/client";
import { ResultType, Status } from "../lib/result";
import { errorResponse, noIdea, successResponse } from "./response";
import { getExhibitsByUserId, getUserIdByUsername } from "./redis/actions";
import { getElmPackages } from "./api";
import { elmLangPackagesToAuthor } from "./common";

export async function handler(
  event: APIGatewayEvent,
  context: Context
): Promise<ResponseBody> {
  const params = event.queryStringParameters;
  if (!params || !params.author) {
    return errorResponse({ tag: "MissingAuthorParam" });
  }
  const author: string = params.author;
  if (redisClient.Status === Status.Err) {
    return errorResponse(noIdea);
  }
  const userIdResult = await getUserIdByUsername(author, redisClient.data);
  if (userIdResult.Status === Status.Err) {
    // check to see if the author has authored elm packages
    // TODO check elm packages cache
    // TODO if cache has expired, get elm packages and then add to cache
    const elmPackagesResult: ResultType<
      ElmLangPackage[]
    > = await getElmPackages();
    if (elmPackagesResult.Status === Status.Err)
      return errorResponse({ tag: "AuthorNotFound" });

    const authorPackages: ElmLangPackage[] = elmLangPackagesToAuthor(
      author,
      elmPackagesResult.data
    );

    if (authorPackages.length === 0)
      return errorResponse({ tag: "AuthorNotFound" });
    // TODO: get user exhibits
    return errorResponse({
      tag: "AuthorNotFoundWithElmLangPackages",
      packages: authorPackages,
    });
  }

  const userExhibits = await getExhibitsByUserId(
    userIdResult.data,
    redisClient.data
  );

  if (userExhibits.Status === Status.Err) return errorResponse(noIdea);

  return successResponse({
    tag: "AuthorExhibitsFetched",
    exhibits: userExhibits.data,
  });
}
