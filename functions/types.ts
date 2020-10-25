import {StatusCodes} from "http-status-codes";

export type NoIdea = { tag: "KeineAhnung" }

export type ExampleErrorBody  =
  { tag: "ExampleBuildFailed" }
  | { tag: "AuthorNotFound", foundAuthor: string }
  | { tag: "PackageNotFound" }
  | { tag: "AuthorAndPackageNotFound" }
  | NoIdea

export type SessionErrorBody =
  { tag: "RefreshFailed" }
  | { tag: "LogInFailed" }
  | NoIdea

export type SessionSuccessTag =
  { tag: "SessionRefreshed" }

export type ErrorBody = ExampleErrorBody | SessionErrorBody

export type ResponseBody =
  {
    statusCode: StatusCodes,
    body: string,
    headers: {
      [key: string]: string
    }
  }

export type RedirectBody =
  {
    statusCode: StatusCodes,
    headers: {
      Location: string
    }
  }
