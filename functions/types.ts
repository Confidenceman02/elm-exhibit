import {StatusCodes} from "http-status-codes";
import {UserSession} from "./redis/schema";

export type NoIdea = { tag: "KeineAhnung" }

export type ExampleErrorBody  =
  { tag: "ExampleBuildFailed" }
  | { tag: "AuthorNotFound", foundAuthor: string }
  | { tag: "PackageNotFound" }
  | { tag: "AuthorAndPackageNotFound" }
  | NoIdea

export type ExampleSuccessBody =
    { tag: "ExamplesFetched", examples: Example[] }

export type SessionErrorBody =
  { tag: "RefreshFailed" }
  | { tag: "LoginFailed" }
  | NoIdea

export type SessionSuccessBody =
  { tag: "SessionRefreshed" }
  | { tag: "Redirecting", location: string }
  | { tag: "SessionGranted", session: UserSession }

export type ErrorBody = ExampleErrorBody | SessionErrorBody

export type SuccessBody = SessionSuccessBody | ExampleSuccessBody

export type TaggedResponseBody = SuccessBody | ErrorBody

export type ResponseBody =
  {
    statusCode: StatusCodes,
    body: string,
    headers: {
      [key: string]: string
    }
  }

interface Example
  {
    id: string,
    name: string,
    description: string
  }

export type GithubUserData = {
  login: string,
  id: number,
  avatar_url: string
}

