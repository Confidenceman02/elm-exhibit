import { APIGatewayEvent, Context } from "aws-lambda";
import { ResponseBody } from "./types";
import { parseCookie } from "./request";
import { ResultType, Status } from "../lib/result";
import { errorResponse, noIdea, successResponse } from "./response";
import { UserSession } from "./redis/schema";
import { destroySession, getSession } from "./redis/actions";
import redisClient from "./redis/client";

export async function handler(
  event: APIGatewayEvent,
  _context: Context
): Promise<ResponseBody> {
  const { cookie } = event.headers;
  const cookieResult = parseCookie(cookie);

  if (redisClient.Status === Status.Err) {
    return errorResponse(noIdea);
  }

  const client = redisClient.data;

  if (cookieResult.Status === Status.Err) {
    return errorResponse({ tag: "MissingCookie" });
  }

  const session: ResultType<UserSession> = await getSession(
    cookieResult.data.session_id,
    client
  );

  if (session.Status === Status.Err) {
    return errorResponse({ tag: "SessionNotFound" });
  }

  const sessionDestroyed: boolean = await destroySession(
    session.data.sessionId,
    client
  );

  if (sessionDestroyed) {
    return successResponse({ tag: "SessionDestroyed" });
  }
  return errorResponse({ tag: "SessionNotFound" });
}
