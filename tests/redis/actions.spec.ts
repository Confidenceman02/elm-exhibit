import redisClientResult from "../../functions/redis/client";
import { expect } from "chai";
import { Status } from "../../lib/result";
import {
  createUser,
  destroySession,
  sessionExists,
  getSession,
  getUser,
  initSession,
  initTempSession,
  tempSessionExists,
  userExists,
} from "../../functions/redis/actions";
import { TempSession } from "../../functions/redis/types";
import { GithubLoginData, GithubUserData } from "../../functions/types";

describe("actions", () => {
  if (redisClientResult.Status === Status.Err) {
    throw new Error("Could not connect to redis client");
  }

  const client = redisClientResult.data;

  beforeEach(() => {
    client.FLUSHALL();
  });
  afterEach(() => {
    client.FLUSHALL();
  });
  describe("initTempSession", () => {
    it("should init a temporary session", async () => {
      const tempSession: TempSession = {
        sessionId: "1234",
        referer: "www.elm-exhibit.com",
      };

      const tempSessionInitiated = await initTempSession(tempSession, client);

      expect(tempSessionInitiated).to.be.true;
    });
  });
  describe("initSession", () => {
    it("should init a session", async () => {
      const sessionId = "1234";
      const gitUserData: GithubUserData = {
        login: "ConfidenceMan02",
        id: 2345,
        avatar_url: "www.bs.com",
      };

      const sessionInitiated = await initSession(
        sessionId,
        gitUserData,
        client
      );

      expect(sessionInitiated).to.be.true;
    });
  });
  describe("tempSessionExists", () => {
    it("should find a temp session", async () => {
      const tempSession: TempSession = {
        sessionId: "1234",
        referer: "www.elm-exhibit.com",
      };
      await initTempSession(tempSession, client);
      const foundTempSession = await tempSessionExists(tempSession, client);

      expect(foundTempSession).to.be.true;
    });
  });
  describe("sessionExists", () => {
    it("should find a session", async () => {
      const sessionId = "1234";
      const gitUserData: GithubUserData = {
        login: "ConfidenceMan02",
        id: 2345,
        avatar_url: "www.bs.com",
      };
      await initSession(sessionId, gitUserData, client);

      const foundSession = await sessionExists(sessionId, client);

      expect(foundSession).to.be.true;
    });
  });
  describe("createUser", () => {
    it("should create a user", async () => {
      const gitUserData: GithubUserData = {
        login: "ConfidenceMan02",
        id: 2345,
        avatar_url: "www.bs.com",
      };
      const loginData: GithubLoginData = {
        access_token: "token 1234",
      };

      const userCreated = await createUser(gitUserData, loginData, client);
      expect(userCreated).to.be.true;
    });
  });
  describe("getUser", () => {
    it("should get a user", async () => {
      const gitUserData: GithubUserData = {
        login: "Confidenceman02",
        id: 2345,
        avatar_url: "www.bs.com",
      };
      const loginData: GithubLoginData = {
        access_token: "token 1234",
      };
      await createUser(gitUserData, loginData, client);

      const user = await getUser(gitUserData.id, client);
      expect(user).to.deep.eq({
        Status: Status.Ok,
        data: {
          username: "Confidenceman02",
          userId: 2345,
          avatarUrl: "www.bs.com",
          accessToken: "token 1234",
        },
      });
    });
  });
  describe("userExists", () => {
    it("should find a user", async () => {
      const gitUserData: GithubUserData = {
        login: "Confidenceman02",
        id: 2345,
        avatar_url: "www.bs.com",
      };
      const loginData: GithubLoginData = {
        access_token: "token 1234",
      };

      await createUser(gitUserData, loginData, client);

      const user = await userExists(gitUserData.id, client);
      expect(user).to.be.true;
    });
    describe("when there is no user", () => {
      it("should not find a user", async () => {
        const gitUserData: GithubUserData = {
          login: "Confidenceman02",
          id: 2345,
          avatar_url: "www.bs.com",
        };

        const user = await userExists(gitUserData.id, client);

        expect(user).to.be.false;
      });
    });
  });
  describe("getSession", () => {
    it("should get a session", async () => {
      const gitUserData: GithubUserData = {
        login: "Confidenceman02",
        id: 2345,
        avatar_url: "www.bs.com",
      };
      await initSession("session123", gitUserData, client);

      const session = await getSession("session123", client);

      expect(session).to.deep.eq({
        Status: Status.Ok,
        data: {
          username: "Confidenceman02",
          userId: 2345,
          avatarUrl: "www.bs.com",
          sessionId: "session123",
        },
      });
    });
  });
  describe("destroySession", () => {
    it("should destroy a session", async () => {
      const gitUserData: GithubUserData = {
        login: "Confidenceman02",
        id: 2345,
        avatar_url: "www.bs.com",
      };
      await initSession("session123", gitUserData, client);

      const seshExists = await sessionExists("session123", client);

      expect(seshExists).to.be.true;

      const sessionDestroyed = await destroySession("session123", client);

      expect(sessionDestroyed).to.be.true;
    });
  });
});
