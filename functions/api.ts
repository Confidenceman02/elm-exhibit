import { Result, ResultType, Status } from "../lib/result";
import { ElmLangPackage } from "./types";
import { getElmPackagesCache, setElmPackagesCache } from "./redis/actions";
import { IPromisifiedRedis } from "./redis/types";
import { fetchElmPackages } from "./fetch";

// getElmPackages has multiple concerns which is not ideal.
// It tries to fetch the elm packages via the cache first and
// if that fails it fetches them from elm-lang.org.
// If it successfully fetches them from elm-lang.org it sets the cache
// for subsequent requests.
export async function getElmPackages(
  client: IPromisifiedRedis
): Promise<ResultType<ElmLangPackage[]>> {
  //  try fetch from cache first
  const cache: ResultType<ElmLangPackage[]> = await getElmPackagesCache(client);
  if (cache.Status === Status.Ok) {
    return cache;
  }
  //  get from elm-lang.org
  const fetchedPackages = await fetchElmPackages();
  if (fetchedPackages.Status === Status.Ok) {
    await setElmPackagesCache(fetchedPackages.data, client);
    return fetchedPackages;
  }
  return Result().Err;
}
