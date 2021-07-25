import { APIGatewayEvent, Context } from "aws-lambda";
import { GithubLoginData, GithubUserData, ResponseBody } from "./types";
import { TempSession } from "./redis/types";
import { ResultType, Status } from "../lib/result";
import { errorResponse, noIdea, successResponse } from "./response";
import {
  createUser,
  getSession,
  initSession,
  tempSessionExists,
  updateUserAccessToken,
  userExists,
} from "./redis/actions";
import { githubLoginEndpoint, githubUserEndpoint } from "./endpoint";
import fetch, { Response } from "node-fetch";
import { acceptJson, withAuth } from "./headers";
import { UserSession } from "./redis/schema";
import redisClient from "./redis/client";
import { URL } from "url";

export async function handler(
  event: APIGatewayEvent,
  _context: Context
): Promise<ResponseBody> {
  const params = event.queryStringParameters;

  if (
    !params ||
    !params.code ||
    !params.state ||
    redisClient.Status === Status.Err
  ) {
    return errorResponse(noIdea);
  }
  const client = redisClient.data;
  const decodedState: string = Buffer.from(params.state, "base64").toString(
    "utf8"
  );

  try {
    const stateParamAsObject: TempSession = JSON.parse(decodedState);
    const sessionId = stateParamAsObject.sessionId;
    const tmpSessionExists: boolean = await tempSessionExists(
      stateParamAsObject,
      client
    );
    const loginEndPoint: ResultType<URL> = githubLoginEndpoint(params.code);
    if (tmpSessionExists && loginEndPoint.Status === Status.Ok) {
      const loginResponse: Response = await fetch(loginEndPoint.data.href, {
        method: "POST",
        headers: { ...acceptJson },
      });
      if (!loginResponse.ok) return errorResponse(noIdea);
      const loginResponseData: GithubLoginData = await loginResponse.json();
      // get user github info
      const githubUserResponse = await fetch(githubUserEndpoint().href, {
        headers: { ...acceptJson, ...withAuth(loginResponseData.access_token) },
      });
      if (!githubUserResponse.ok) return errorResponse(noIdea);
      // TODO: Validate data
      const parsedGithubUserResponse: GithubUserData =
        await githubUserResponse.json();
      // initiate a session
      const initiatedSession: boolean = await initSession(
        sessionId,
        parsedGithubUserResponse,
        client
      );
      const fetchedSession: ResultType<UserSession> = await getSession(
        sessionId,
        client
      );
      if (initiatedSession && fetchedSession.Status === Status.Ok) {
        // check for a existing user as maybe the cookie expired or they revoked the app.
        const existingUser: boolean = await userExists(
          parsedGithubUserResponse.id,
          client
        );
        if (existingUser) {
          const updatedAccessToken = await updateUserAccessToken(
            parsedGithubUserResponse.id,
            loginResponseData.access_token,
            client
          );
          if (updatedAccessToken)
            return successResponse({
              tag: "SessionGranted",
              session: fetchedSession.data,
            });
          return errorResponse(noIdea);
        }
        // create user if this is first time logging in
        const createdUser: boolean = await createUser(
          parsedGithubUserResponse,
          loginResponseData,
          client
        );
        if (createdUser) {
          return successResponse({
            tag: "SessionGranted",
            session: fetchedSession.data,
          });
        }
        return errorResponse({ tag: "LoginFailed" });
      }
      return errorResponse({ tag: "LoginFailed" });
    }
    return errorResponse({ tag: "LoginFailed" });
  } catch (e) {
    return errorResponse(noIdea);
  }
}
