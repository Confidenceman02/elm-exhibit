import Cookie from "cookie"
import {Result, ResultType} from "../lib/result";
import {SessionCookie} from "./types";
import {sessionIdCookieKey} from "./headers";

export function parseCookie(cookie: string | undefined): ResultType<SessionCookie> {
  if (!cookie) {
    return Result().Err
  }
  const parsedCookie = Cookie.parse(cookie)
  if(sessionIdCookieKey in parsedCookie) {
    return Result<SessionCookie>().Ok({ session_id: parsedCookie[sessionIdCookieKey] })
  }
  return Result().Err
}