import {StatusCodes} from "http-status-codes";

export type ExampleErrorBody  =
  { tag: "ExampleBuildFailed" }
  | { tag: "AuthorNotFound", foundAuthor: string }
  | { tag: "PackageNotFound" }
  | { tag: "AuthorAndPackageNotFound" }
  | { tag: "KeineAhnung" }

export type ErrorBody = ExampleErrorBody

export type ResponseBody =
  {
    statusCode: StatusCodes,
    body: string,
    headers: {
      [key: string]: string
    }
  }