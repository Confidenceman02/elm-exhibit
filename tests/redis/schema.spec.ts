import {
  redisUserSessionUserSession,
  redisUserToUser,
  RedisHValue,
  User,
  UserSession,
  redisUserIdToUserId,
} from "../../functions/redis/schema";
import { expect } from "chai";
import { Status } from "../../lib/result";

describe("schema", () => {
  describe("redisReturnValueToUser", () => {
    it("should return user", () => {
      const redisHValue: RedisHValue<User> = {
        username: "confidenceman02",
        userId: "1234",
        avatarUrl: "www.bs.com",
        accessToken: "token 1234",
      };
      expect(redisUserToUser(redisHValue)).to.deep.eq({
        Status: Status.Ok,
        data: {
          username: "confidenceman02",
          userId: 1234,
          avatarUrl: "www.bs.com",
          accessToken: "token 1234",
        },
      });
    });

    it("should return error result", () => {
      const redisHValue = null;
      expect(redisUserToUser(redisHValue)).to.deep.eq({
        Status: Status.Err,
      });
    });
  });

  describe("redisUserSessionToUserSession", () => {
    it("should return user session", () => {
      const redisHValue: RedisHValue<UserSession> = {
        username: "confidenceman02",
        userId: "1234",
        avatarUrl: "www.bs.com",
        sessionId: "sessionId123",
      };
      expect(redisUserSessionUserSession(redisHValue)).to.deep.eq({
        Status: Status.Ok,
        data: {
          username: "confidenceman02",
          userId: 1234,
          avatarUrl: "www.bs.com",
          sessionId: "sessionId123",
        },
      });
    });

    it("should return error result when null redisHValue", () => {
      expect(redisUserSessionUserSession(null)).to.deep.eq({
        Status: Status.Err,
      });
    });
  });

  describe("redisUserIdToUserId", () => {
    it("should return a user id", () => {
      const username = "1234";
      expect(redisUserIdToUserId(username)).to.deep.eq({
        Status: Status.Ok,
        data: 1234,
      });
    });

    it("should return error result when null", () => {
      const username = null;
      expect(redisUserIdToUserId(username)).to.deep.eq({
        Status: Status.Err,
      });
    });

    it("should return error result when string is NaN", () => {
      // javascript considers "NaN" a number.. FFS!
      const username = "NaN";
      expect(redisUserIdToUserId(username)).to.deep.eq({
        Status: Status.Err,
      });
    });
  });
});
