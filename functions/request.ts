import { parse } from "cookie";
import { Result, ResultType } from "../lib/result";
import { SessionCookie } from "./types";
import { sessionIdCookieKey } from "./headers";
import { NODE_ENV } from "./env";

export function parseCookie(
  cookie: string | undefined
): ResultType<SessionCookie> {
  if (!cookie) {
    return Result().Err;
  }
  const parsedCookie = parse(cookie);
  if (
    sessionIdCookieKey in parsedCookie &&
    parsedCookie[sessionIdCookieKey] !== ""
  ) {
    return Result<SessionCookie>().Ok({
      session_id: parsedCookie[sessionIdCookieKey],
    });
  }
  return Result().Err;
}

function resolveBackupReferer(): string {
  if (NODE_ENV) {
    switch (NODE_ENV) {
      case "development":
        return "http://localhost:8888";
      case "production":
        return "https://elm-exhibit.com";
      default:
        return "http://localhost:8888";
    }
  } else {
    return "http://localhost:8888";
  }
}

export function resolveReferer(referer: undefined | string): string {
  if (referer) {
    return referer;
  } else {
    return resolveBackupReferer();
  }
}
