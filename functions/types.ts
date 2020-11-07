import {StatusCodes} from "http-status-codes";

export type NoIdea = { tag: "KeineAhnung" }

export type ExampleErrorBody  =
  { tag: "ExampleBuildFailed" }
  | { tag: "AuthorNotFound", foundAuthor: string }
  | { tag: "PackageNotFound" }
  | { tag: "AuthorAndPackageNotFound" }
  | NoIdea

export type ExampleSuccessBody =
    { examples: Example[] }

export type SessionErrorBody =
  { tag: "RefreshFailed" }
  | { tag: "LogInFailed" }
  | NoIdea

export type SessionSuccessBody =
  { tag: "SessionRefreshed" }
  | { tag: "Redirecting", location: string }
  | { tag: "SessionGranted" }

export type ErrorBody = ExampleErrorBody | SessionErrorBody

export type SuccessBody = SessionSuccessBody | ExampleSuccessBody

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

export interface TempSession
{
  tempSessionId: string;
  referer: string;
}

export enum Status {
    Err,
    Ok
}

export type ResultTuple<T> = ([Status.Ok, T] | [Status.Err, undefined])

export interface ResultResolver<T>
{
  Err: [Status.Err, undefined];
  Ok: (arg: T) => [Status.Ok, T]
}

