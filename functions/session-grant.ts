import {APIGatewayEvent, Context} from "aws-lambda";
import {RedirectBody, ResponseBody} from "./types";
import {StatusCodes} from "http-status-codes";
import {URL} from "url";
import {errorResponse} from "./common";

const gitHubClientId: string | undefined = process.env.GITHUB_CLIENT_ID
const githubLoginEndpoint: URL = new URL("https://github.com/login/oauth/authorize")

export async function handler(event: APIGatewayEvent, context: Context): Promise<RedirectBody | ResponseBody> {
  if (gitHubClientId) {
    console.log(gitHubClientId)
    githubLoginEndpoint.searchParams.append("client_id", gitHubClientId)
    return {
      statusCode: StatusCodes.SEE_OTHER,
      headers: {
        "Location": githubLoginEndpoint.href
      }
    }
  }
  return errorResponse(StatusCodes.INTERNAL_SERVER_ERROR, { tag: "LogInFailed" })
}
