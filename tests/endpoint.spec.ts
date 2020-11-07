import {githubLoginEndpoint} from "../functions/endpoint";
import {expect} from "chai";
import {ResultType, Status} from "../functions/types";

describe('githubLoginEndpoint', () => {
  it('should return github login endpoint href with auth params', () => {
    const endPointResult: ResultType<URL> = githubLoginEndpoint('1234')
    expect(endPointResult.Status).to.eq(Status.Ok)
    if (endPointResult.Status === Status.Ok) {
      expect(endPointResult.data.href).to.eq('https://github.com/login/oauth/access_token?code=1234&client_id=test-client-id&client_secret=test-client-secret')
    }
  })
})