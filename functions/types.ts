import {StatusCodes} from "http-status-codes";

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
  | { tag: "LogInFailed" }
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

export interface TempSession {
  sessionId: string;
  referer: string;
}

export type GithubUserData = {
  login: string,
  id: number,
  avatar_url: string
}

export type UserSession = {
  username: string,
  userId: string
  avatarUrl: string,
  sessionId: string
}
