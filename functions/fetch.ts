import { Result, ResultType } from "../lib/result";
import { ElmLangPackage } from "./types";
import fetch, { Response } from "node-fetch";
import { elmPackageSearchEndpoint } from "./endpoint";
import { acceptJson } from "./headers";

export async function fetchElmPackages(): Promise<
  ResultType<ElmLangPackage[]>
> {
  const elmPackageSearchResponse: Response = await fetch(
    elmPackageSearchEndpoint().href,
    {
      method: "GET",
      headers: { ...acceptJson },
    }
  );
  if (!elmPackageSearchResponse.ok) return Result().Err;
  const elmPackages: ElmLangPackage[] = await elmPackageSearchResponse.json();
  return Result<ElmLangPackage[]>().Ok(elmPackages);
}
