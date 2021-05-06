import { APIGatewayEvent, Context } from "aws-lambda";
import { ResponseBody } from "./types";
import { errorResponse, successResponse } from "./response";
import { v4 as uuidv4 } from "uuid";
import { getSession, initTempSession } from "./redis/actions";
import redisClient from "./redis/client";
import { Status } from "../lib/result";
import { githubAuthorizeEndpoint } from "./endpoint";
import { parseCookie, resolveReferer } from "./request";

export async function handler(
  event: APIGatewayEvent,
  _context: Context
): Promise<ResponseBody> {
  const { referer, cookie } = event.headers;
  const sessionId = uuidv4();
  const resolvedReferer: string = resolveReferer(referer);
  const authEndpoint = githubAuthorizeEndpoint(sessionId, resolvedReferer);
  const cookieResult = parseCookie(cookie);

  if (redisClient.Status === Status.Err) {
    return errorResponse({ tag: "LoginFailed" });
  }

  const client = redisClient.data;

  // when no cookie
  if (cookieResult.Status === Status.Err) {
    // TODO: Handle when cookie session ends but there is a cached session. This avoids doing the auth callback.
    // save temporary session meta
    const tempSession = await initTempSession(
      { sessionId, referer: resolvedReferer },
      client
    );
    if (tempSession && authEndpoint.Status === Status.Ok) {
      return successResponse({
        tag: "Redirecting",
        location: authEndpoint.data.href,
      });
    }
    return errorResponse({ tag: "LoginFailed" });
  }

  const sessionResult = await getSession(cookieResult.data.session_id, client);
  if (sessionResult.Status === Status.Err) {
    return errorResponse({ tag: "LoginFailed" });
  }
  return successResponse({
    tag: "SessionGranted",
    session: sessionResult.data,
  });
}
