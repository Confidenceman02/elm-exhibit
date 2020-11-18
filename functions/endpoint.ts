import {Result, ResultType} from "../lib/result";
import { URL } from "url";

const GITHUB_OAUTH_LOGIN_ENDPOINT =  "https://github.com/login/oauth/access_token"
const GITHUB_OAUTH_AUTHORIZE_ENDPOINT = "https://github.com/login/oauth/authorize"
const GITHUB_USER_ENDPOINT =  "https://api.github.com/user"
const GITHUB_CLIENT_ID: string | undefined = process.env.GITHUB_CLIENT_ID
const GITHUB_CLIENT_SECRET: string | undefined = process.env.GITHUB_CLIENT_SECRET

export function githubLoginEndpoint(code: string): ResultType<URL> {
  const endpointUrl: URL = new URL(GITHUB_OAUTH_LOGIN_ENDPOINT)
  endpointUrl.searchParams.append("code", code)
  if (GITHUB_CLIENT_ID && GITHUB_CLIENT_SECRET) {
    endpointUrl.searchParams.append("client_id", GITHUB_CLIENT_ID)
    endpointUrl.searchParams.append("client_secret", GITHUB_CLIENT_SECRET)
    return Result<URL>().Ok(endpointUrl)
  }
  return Result().Err
}

export function githubUserEndpoint(): URL {
  return new URL(GITHUB_USER_ENDPOINT)
}

export function githubAuthorizeEndpoint(sessionId: string, referer: string): ResultType<URL> {
  const endPoint = new URL(GITHUB_OAUTH_AUTHORIZE_ENDPOINT)
  const stateAsJSON: string = JSON.stringify({ sessionId: sessionId, referer: referer })
  const encodedState: string = Buffer.from(stateAsJSON, "utf8").toString("base64")
  if (GITHUB_CLIENT_ID) {
    endPoint.searchParams.append("client_id", GITHUB_CLIENT_ID)
    endPoint.searchParams.append("state", encodedState)
    return Result<URL>().Ok(endPoint)
  }
  return Result().Err
}
