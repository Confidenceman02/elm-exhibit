import { ResultType, Status } from "../lib/result";
import { ElmLangPackage } from "./types";
import { getElmPackagesCache } from "./redis/actions";
import { IPromisifiedRedis } from "./redis/types";
import { fetchElmPackages } from "./fetch";

export async function getElmPackages(
  client: IPromisifiedRedis
): Promise<ResultType<ElmLangPackage[]>> {
  //  try fetch from cache first
  const cache: ResultType<ElmLangPackage[]> = await getElmPackagesCache(client);
  if (cache.Status === Status.Ok) return cache;
  //  get from elm-lang
  const packages = await fetchElmPackages();
  return packages;
}
