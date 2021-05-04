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
  getUserIdByUsername,
  getExhibitReferencesByUserId,
  getUsernameByUserId,
  createExhibitReference,
  updateUserAccessToken,
  getElmPackagesCache,
  setElmPackagesCache,
} from "../../functions/redis/actions";
import { TempSession } from "../../functions/redis/types";
import {
  ElmLangPackage,
  GithubLoginData,
  GithubUserData,
} from "../../functions/types";
import { generateElmPackagesCacheKey } from "../../functions/redis/common";

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

    it("should not find a temp session", async () => {
      const tempSession: TempSession = {
        sessionId: "1234",
        referer: "www.elm-exhibit.com",
      };

      const foundTempSession = await tempSessionExists(tempSession, client);

      expect(foundTempSession).to.be.false;
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

    it("should not find a session", async () => {
      const sessionId = "1234";

      const foundSession = await sessionExists(sessionId, client);

      expect(foundSession).to.be.false;
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
    it("should get a user result", async () => {
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

    it("should not find a user", async () => {
      const gitUserData: GithubUserData = {
        login: "Confidenceman02",
        id: 2345,
        avatar_url: "www.bs.com",
      };
      const user = await getUser(gitUserData.id, client);
      expect(user).to.deep.eq({
        Status: Status.Err,
      });
    });
  });

  describe("userExists", () => {
    it("user should exist", async () => {
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

    it("should not find a session", async () => {
      const session = await getSession("session123", client);

      expect(session).to.deep.eq({
        Status: Status.Err,
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

  describe("getUserIdByUsername", () => {
    it("should return Ok userId result", async () => {
      const gitUserData: GithubUserData = {
        login: "Confidenceman02",
        id: 2345,
        avatar_url: "www.bs.com",
      };
      const loginData: GithubLoginData = {
        access_token: "token 1234",
      };
      await createUser(gitUserData, loginData, client);
      const userIdResult = await getUserIdByUsername("Confidenceman02", client);

      expect(userIdResult).to.deep.eq({
        Status: Status.Ok,
        data: 2345,
      });
    });
    it("should return Err userId result", async () => {
      const userIdResult = await getUserIdByUsername("Confidenceman02", client);
      expect(userIdResult).to.deep.eq({
        Status: Status.Err,
      });
    });
  });

  describe("getExhibitReferencesByUserId", () => {
    it("should return exhibit references", async () => {
      const gitUserData: GithubUserData = {
        login: "Confidenceman02",
        id: 2345,
        avatar_url: "www.bs.com",
      };
      const loginData: GithubLoginData = {
        access_token: "token 1234",
      };

      await createUser(gitUserData, loginData, client);
      await createExhibitReference(
        gitUserData.id,
        "elm-animate-height",
        client
      );
      await createExhibitReference(gitUserData.id, "elm-select", client);

      const exhibitReferences = await getExhibitReferencesByUserId(
        gitUserData.id,
        client
      );
      expect(exhibitReferences).to.deep.eq({
        Status: Status.Ok,
        data: [
          "Confidenceman02.elm-animate-height.exhibit",
          "Confidenceman02.elm-select.exhibit",
        ],
      });
    });
    it("should return no exhibit references", async () => {
      const userReferences = await getExhibitReferencesByUserId(1, client);
      expect(userReferences).to.deep.eq({
        Status: Status.Ok,
        data: [],
      });
    });
  });

  describe("createExhibitReference", () => {
    it("should create a exhibit reference", async () => {
      const gitUserData: GithubUserData = {
        login: "Confidenceman02",
        id: 2345,
        avatar_url: "www.bs.com",
      };
      const loginData: GithubLoginData = {
        access_token: "token 1234",
      };

      await createUser(gitUserData, loginData, client);
      const exhibitReferenceCreated = await createExhibitReference(
        2345,
        "someExhibit",
        client
      );

      expect(exhibitReferenceCreated).to.be.true;
    });
    it("should not create an exhibit reference without a created user", async () => {
      const userReferenceCreated = await createExhibitReference(
        1,
        "elm-animate-height",
        client
      );

      expect(userReferenceCreated).to.be.false;
    });
  });

  describe("getUsernameByUserId", () => {
    it("should get a user name", async () => {
      const gitUserData: GithubUserData = {
        login: "Confidenceman02",
        id: 2345,
        avatar_url: "www.bs.com",
      };
      const loginData: GithubLoginData = {
        access_token: "token 1234",
      };

      await createUser(gitUserData, loginData, client);
      const username = await getUsernameByUserId(2345, client);

      expect(username).to.deep.eq({
        Status: Status.Ok,
        data: "Confidenceman02",
      });
    });
  });

  describe("updateUserAccessToken", () => {
    it("should update access token", async () => {
      const gitUserData: GithubUserData = {
        login: "Confidenceman02",
        id: 2345,
        avatar_url: "www.bs.com",
      };
      const loginData: GithubLoginData = {
        access_token: "token 1234",
      };

      await createUser(gitUserData, loginData, client);
      const updated = await updateUserAccessToken(2345, "token 1111", client);

      expect(updated).to.be.true;
    });
    it("should not update the access token", async () => {
      const updated = await updateUserAccessToken(2345, "token 1111", client);

      expect(updated).to.be.false;
    });
  });

  describe("setElmPackagesCache", () => {
    it("should set elm packages cache with a key expiry", async () => {
      const packagesCache: ElmLangPackage[] = [
        { name: "Confidenceman02/elm-exhibit" },
        { name: "Confidenceman02/elm-animate-height" },
        { name: "Confidenceman02/elm-select" },
        { name: "Someone/elm-something" },
      ];

      const elmPackagesSet: boolean = await setElmPackagesCache(
        packagesCache,
        client
      );

      const expiryTimeRemaining: number = await client.TTLAsync(
        generateElmPackagesCacheKey()
      );

      expect(elmPackagesSet).to.be.true;
      expect(expiryTimeRemaining).to.not.eq(-1);
    });
  });

  describe("getElmPackagesCache", () => {
    it("should return Err result when it doesnt exist", async () => {
      const packagesCache = await getElmPackagesCache(client);

      expect(packagesCache).to.deep.eq({
        Status: Status.Err,
      });
    });
    it("should return all elm packages", async () => {
      const packagesCache: ElmLangPackage[] = [
        { name: "Confidenceman02/elm-exhibit" },
        { name: "Confidenceman02/elm-animate-height" },
        { name: "Confidenceman02/elm-select" },
        { name: "Someone/elm-something" },
      ];

      await setElmPackagesCache(packagesCache, client);
      const elmPackagesCache = await getElmPackagesCache(client);

      expect(elmPackagesCache).to.deep.eq({
        Status: Status.Ok,
        data: [
          { name: "Confidenceman02/elm-exhibit" },
          { name: "Confidenceman02/elm-animate-height" },
          { name: "Confidenceman02/elm-select" },
          { name: "Someone/elm-something" },
        ],
      });
    });
  });
});
