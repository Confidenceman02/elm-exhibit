import { StatusCodes } from "http-status-codes";
import { UserSession } from "./redis/schema";

export type NoIdea = { tag: "KeineAhnung" };

export type AuthorExhibitsErrorBody =
  | { tag: "AuthorNotFound" }
  | { tag: "MissingAuthor" };

export type ExampleErrorBody =
  | { tag: "AuthorNotFound" }
  | { tag: "ExhibitNotFound" }
  | { tag: "AuthorAndExhibitNotFound" }
  | NoIdea;

export type ExampleSuccessBody = {
  tag: "ExamplesFetched";
  examples: Example[];
};

export type SessionErrorBody =
  | { tag: "RefreshFailed" }
  | { tag: "LoginFailed" }
  | { tag: "SessionNotFound" }
  | { tag: "MissingCookie" }
  | NoIdea;

export type SessionSuccessBody =
  | { tag: "SessionRefreshed"; session: UserSession }
  | { tag: "Redirecting"; location: string }
  | { tag: "SessionGranted"; session: UserSession }
  | { tag: "SessionDestroyed" };

export type ErrorBody =
  | ExampleErrorBody
  | SessionErrorBody
  | AuthorExhibitsErrorBody;

export type SuccessBody = SessionSuccessBody | ExampleSuccessBody;

export type TaggedResponseBody = SuccessBody | ErrorBody;

export type ResponseBody = {
  statusCode: StatusCodes;
  body: string;
  headers: {
    [key: string]: string;
  };
};

export interface Example {
  id: string;
  name: string;
  description: string;
}

export interface Exhibit {
  name: string;
}

export type GithubUserData = {
  login: string;
  id: number;
  avatar_url: string;
};

export type GithubLoginData = {
  access_token: string;
};

export type SessionCookie = {
  [K in "session_id"]: string;
};
