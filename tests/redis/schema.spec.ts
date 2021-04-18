import {
  redisValueToUserSession,
  redisReturnValueToUser,
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
      expect(redisReturnValueToUser(redisHValue)).to.deep.eq({
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
      expect(redisReturnValueToUser(redisHValue)).to.deep.eq({
        Status: Status.Err,
      });
    });
  });
  describe("redisValueToUserSession", () => {
    it("should return user session", () => {
      const redisHValue: RedisHValue<UserSession> = {
        username: "confidenceman02",
        userId: "1234",
        avatarUrl: "www.bs.com",
        sessionId: "sessionId123",
      };
      expect(redisValueToUserSession(redisHValue)).to.deep.eq({
        username: "confidenceman02",
        userId: 1234,
        avatarUrl: "www.bs.com",
        sessionId: "sessionId123",
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
