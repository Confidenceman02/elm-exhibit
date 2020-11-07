import {StatusCodes} from "http-status-codes";
import {ErrorBody, NoIdea, ResponseBody, SuccessBody} from "./types";

export function errorResponse(error: ErrorBody): ResponseBody {
  return {
    statusCode: resolveStatusCodeFromErrorBody(error),
    body: JSON.stringify(error),
    headers: {
     ...jsonHeaders
    }
  }
}

export function successBody(statusCode: StatusCodes, body: SuccessBody): ResponseBody {
  return {
    statusCode: statusCode,
    body: JSON.stringify(body),
    headers: {
      ...jsonHeaders
    }
  }

}

export const noIdea: NoIdea = { tag: "KeineAhnung" }

export const jsonHeaders = {
  "Content-Type": "application/json"
}

function resolveStatusCodeFromErrorBody(error: ErrorBody): StatusCodes {
  switch (error.tag) {
    case "ExampleBuildFailed":
      return StatusCodes.BAD_REQUEST
    case "AuthorNotFound":
      return StatusCodes.NOT_FOUND
    case "PackageNotFound":
      return StatusCodes.NOT_FOUND
    case "AuthorAndPackageNotFound":
      return StatusCodes.NOT_FOUND
    case "RefreshFailed":
      return StatusCodes.NOT_FOUND
    case "LogInFailed":
      return StatusCodes.INTERNAL_SERVER_ERROR
    default:
      return StatusCodes.BAD_REQUEST
  }
}