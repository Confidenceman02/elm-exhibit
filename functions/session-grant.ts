import { APIGatewayEvent, Context } from "aws-lambda";
import { RedirectBody, ResponseBody } from "./types";
import { StatusCodes } from "http-status-codes";
import { URL } from "url";
import { errorResponse, jsonHeaders } from "./common";

const gitHubClientId: string | undefined = process.env.GITHUB_CLIENT_ID
const githubLoginEndpoint: URL = new URL("https://github.com/login/oauth/authorize")

export async function handler(event: APIGatewayEvent, context: Context): Promise<ResponseBody> {
  if (gitHubClientId) {
    console.log(event.headers)
    githubLoginEndpoint.searchParams.append("client_id", gitHubClientId)

    return {
      statusCode: StatusCodes.OK,
      body: JSON.stringify({ tag: "Redirecting", location: githubLoginEndpoint.href }),
      headers: {
        ...jsonHeaders
      }
    }
  }

  return errorResponse(StatusCodes.INTERNAL_SERVER_ERROR, { tag: "LogInFailed" })
}
