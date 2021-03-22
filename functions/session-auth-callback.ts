import { APIGatewayEvent, Context } from "aws-lambda";
import { GithubUserData, ResponseBody } from "./types";
import { TempSession } from "./redis/types";
import { ResultType, Status } from "../lib/result";
import { errorResponse, noIdea, successResponse } from "./response";
import {
  createUser,
  getSession,
  initSession,
  tempSessionExists,
  userExists,
} from "./redis/actions";
import { githubLoginEndpoint, githubUserEndpoint } from "./endpoint";
import fetch from "node-fetch";
import { acceptJson, withAuth } from "./headers";
import { UserSession } from "./redis/schema";
import redisClient from "./redis/client";

export async function handler(
  event: APIGatewayEvent,
  context: Context
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
    const tmpSessionExists = await tempSessionExists(
      stateParamAsObject,
      client
    );
    const loginEndPoint: ResultType<URL> = githubLoginEndpoint(params.code);
    if (tmpSessionExists && loginEndPoint.Status === Status.Ok) {
      const response = await fetch(loginEndPoint.data.href, {
        method: "POST",
        headers: { ...acceptJson },
      });
      const responseData = await response.json();
      // get user github info
      const githubUserResponse = await fetch(githubUserEndpoint().href, {
        headers: { ...acceptJson, ...withAuth(responseData.access_token) },
      });
      if (!githubUserResponse.ok) {
        return errorResponse(noIdea);
      }
      const parsedGithubUserResponse: GithubUserData = await githubUserResponse.json();
      // initiate a session
      const initiatedSession: boolean = await initSession(
        sessionId,
        parsedGithubUserResponse,
        client
      );
      const session: ResultType<UserSession> = await getSession(
        sessionId,
        client
      );
      if (initiatedSession && session.Status === Status.Ok) {
        // check for a existing user as maybe the cookie expired or they revoked the app.
        const usrExists = await userExists(parsedGithubUserResponse.id, client);
        if (usrExists) {
          return successResponse({
            tag: "SessionGranted",
            session: session.data,
          });
        }
        // create user if this is their first time logging in
        const createdUser: boolean = await createUser(
          parsedGithubUserResponse,
          client
        );
        if (createdUser) {
          return successResponse({
            tag: "SessionGranted",
            session: session.data,
          });
        }
        return errorResponse({ tag: "LoginFailed" });
      }
      return errorResponse({ tag: "LoginFailed" });
    }
    return errorResponse({ tag: "LoginFailed" });
  } catch (e) {
    console.log(e);
    return errorResponse(noIdea);
  }
}
