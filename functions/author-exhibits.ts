import { APIGatewayEvent, Context } from "aws-lambda";
import { ElmLangPackage, ResponseBody } from "./types";
import redisClient from "./redis/client";
import { ResultType, Status } from "../lib/result";
import { errorResponse, noIdea, successResponse } from "./response";
import {
  getElmPackagesCache,
  getExhibitsByUserId,
  getUserIdByUsername,
  setElmPackagesCache,
} from "./redis/actions";
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
  const client = redisClient.data;
  const userIdResult = await getUserIdByUsername(author, client);
  if (userIdResult.Status === Status.Err) {
    // check elm packages cache
    const elmPackagesCache = await getElmPackagesCache(client);
    if (elmPackagesCache.Status === Status.Ok) {
      //  resolve from cache
      const authorPackages: ElmLangPackage[] = elmLangPackagesToAuthor(
        author,
        elmPackagesCache.data
      );

      if (authorPackages.length === 0)
        return errorResponse({ tag: "AuthorNotFound" });
      return errorResponse({
        tag: "AuthorNotFoundWithElmLangPackages",
        packages: authorPackages,
      });
    }
    // No cache at this point so retrieve packages from elm-lang
    const elmPackagesResult: ResultType<
      ElmLangPackage[]
    > = await getElmPackages();
    if (elmPackagesResult.Status === Status.Err)
      return errorResponse({ tag: "AuthorNotFound" });
    // cache result, we dont care if it actually works
    await setElmPackagesCache(elmPackagesResult.data, client);
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

  const userExhibits = await getExhibitsByUserId(userIdResult.data, client);

  if (userExhibits.Status === Status.Err) return errorResponse(noIdea);

  return successResponse({
    tag: "AuthorExhibitsFetched",
    exhibits: userExhibits.data,
  });
}
