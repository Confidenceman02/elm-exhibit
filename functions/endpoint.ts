import {ResultType} from "./types";
import {Result} from "./common";

const GITHUB_OAUTH_LOGIN_ENDPOINT =  "https://github.com/login/oauth/access_token"
const GITHUB_CLIENT_ID: string | undefined = process.env.GITHUB_CLIENT_ID
const GITHUB_CLIENT_SECRET: string | undefined = process.env.GITHUB_CLIENT_SECRET

export function githubLoginEndpoint(code: string): ResultType<URL> {
  const endpointUrl = new URL(GITHUB_OAUTH_LOGIN_ENDPOINT)
  endpointUrl.searchParams.append("code", code)
  if (GITHUB_CLIENT_ID && GITHUB_CLIENT_SECRET) {
    endpointUrl.searchParams.append("client_id", GITHUB_CLIENT_ID)
    endpointUrl.searchParams.append("client_secret", GITHUB_CLIENT_SECRET)
    return Result<URL>().Ok(endpointUrl)
  } else {
    return Result().Err
  }
}
