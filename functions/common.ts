import { StatusCodes } from "http-status-codes";
import {ErrorBody, NoIdea, ResponseBody} from "./types";

export function errorResponse(statusCode: StatusCodes, error: ErrorBody): ResponseBody {
  return {
    statusCode: statusCode,
    body: JSON.stringify(error),
    headers: {
      "Content-Type": "application/json"
    }
  }
}

export function removeWhiteSpace(value: string): string {
  return value.replace(/\s/g, '')
}

export const jsonHeaders = {
  "Content-Type": "application/json"
}

export const noIdea: NoIdea = { tag: "KeineAhnung" }