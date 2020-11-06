import {StatusCodes} from "http-status-codes";
import {ErrorBody, NoIdea, ResponseBody, SuccessBody} from "./types";

export function errorResponse(statusCode: StatusCodes, error: ErrorBody): ResponseBody {
  return {
    statusCode: statusCode,
    body: JSON.stringify(error),
    headers: {
      "Content-Type": "application/json"
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
