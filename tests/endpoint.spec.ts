import {
  elmPackageSearchEndpoint,
  githubAuthorizeEndpoint,
  githubLoginEndpoint,
  githubUserEndpoint,
} from "../functions/endpoint";
import { expect } from "chai";
import { ResultType, Status } from "../lib/result";
import { URL } from "url";

describe("githubLoginEndpoint", () => {
  it("should return github login endpoint href with auth params", () => {
    const endPointResult: ResultType<URL> = githubLoginEndpoint("1234");

    expect(endPointResult.Status).to.eq(Status.Ok);
    if (endPointResult.Status === Status.Ok) {
      expect(endPointResult.data.href).to.eq(
        "https://github.com/login/oauth/access_token?code=1234&client_id=test-client-id&client_secret=test-client-secret"
      );
    }
  });
});

describe("githubUserEndpoint", () => {
  it("should return github user endpoint href", () => {
    const endPoint: URL = githubUserEndpoint();

    expect(endPoint.href).to.eq("https://api.github.com/user");
  });
});

describe("githubAuthorizeEndpoint", () => {
  it("should return github authorize endpoint href", () => {
    const sessionId = "1234";
    const state = "stateValue";

    const endPoint: ResultType<URL> = githubAuthorizeEndpoint(sessionId, state);

    expect(endPoint.Status).to.eq(Status.Ok);
    if (endPoint.Status === Status.Ok) {
      expect(endPoint.data.href).to.eq(
        "https://github.com/login/oauth/authorize?client_id=test-client-id&state=eyJzZXNzaW9uSWQiOiIxMjM0IiwicmVmZXJlciI6InN0YXRlVmFsdWUifQ%3D%3D"
      );
    }
  });
});

describe("elmPackageSearchEndpoint", () => {
  it("should return the elm package search endpoint href", () => {
    const endpoint: URL = elmPackageSearchEndpoint();

    expect(endpoint.href).to.eq("https://package.elm-lang.org/search.json");
  });
});
