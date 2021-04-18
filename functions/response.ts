import { StatusCodes } from "http-status-codes";
import {
  ErrorBody,
  NoIdea,
  ResponseBody,
  SuccessBody,
  TaggedResponseBody,
} from "./types";
import {
  jsonHeaders,
  withExpireSessionCookie,
  withSetSessionCookie,
} from "./headers";

export function errorResponse(error: ErrorBody): ResponseBody {
  return {
    statusCode: resolveStatusCodeFromErrorBody(error),
    body: JSON.stringify(error),
    headers: {
      ...jsonHeaders,
    },
  };
}

export function successResponse(body: SuccessBody): ResponseBody {
  return {
    statusCode: resolveStatusCodeFromSuccessBody(body),
    body: JSON.stringify(body),
    headers: {
      ...resolveHeadersFromTaggedResponseBody(body),
    },
  };
}

export const noIdea: NoIdea = { tag: "KeineAhnung" };

function resolveStatusCodeFromErrorBody(error: ErrorBody): StatusCodes {
  switch (error.tag) {
    case "ExampleBuildFailed":
      return StatusCodes.BAD_REQUEST;
    case "AuthorNotFound":
      return StatusCodes.NOT_FOUND;
    case "ExhibitNotFound":
      return StatusCodes.NOT_FOUND;
    case "AuthorAndExhibitNotFound":
      return StatusCodes.NOT_FOUND;
    case "RefreshFailed":
      return StatusCodes.NOT_FOUND;
    case "LoginFailed":
      return StatusCodes.INTERNAL_SERVER_ERROR;
    case "SessionNotFound":
      return StatusCodes.NOT_FOUND;
    case "MissingCookie":
      return StatusCodes.BAD_REQUEST;
    case "MissingAuthor":
      return StatusCodes.BAD_REQUEST;
    default:
      return StatusCodes.INTERNAL_SERVER_ERROR;
  }
}

function resolveStatusCodeFromSuccessBody(
  successBody: SuccessBody
): StatusCodes {
  switch (successBody.tag) {
    case "ExamplesFetched":
      return StatusCodes.OK;
    case "SessionRefreshed":
      return StatusCodes.OK;
    case "SessionGranted":
      return StatusCodes.OK;
    case "Redirecting":
      return StatusCodes.OK;
    case "SessionDestroyed":
      return StatusCodes.OK;
    default:
      return StatusCodes.INTERNAL_SERVER_ERROR;
  }
}

function resolveHeadersFromTaggedResponseBody(taggedBody: TaggedResponseBody) {
  switch (taggedBody.tag) {
    case "SessionGranted":
      return { ...jsonHeaders, ...withSetSessionCookie(taggedBody.session) };
    case "SessionDestroyed":
      return { ...jsonHeaders, ...withExpireSessionCookie() };
    default:
      return { ...jsonHeaders };
  }
}
