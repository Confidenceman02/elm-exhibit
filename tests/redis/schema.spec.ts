import {
  redisValueToUserSession,
  redisValueToUser,
  RedisHValue,
  User,
  UserSession,
} from "../../functions/redis/schema";
import { expect } from "chai";

describe("schema", () => {
  describe("redisValueToUser", () => {
    it("should return user", () => {
      const redisHValue: RedisHValue<User> = {
        username: "confidenceman02",
        userId: "1234",
        avatarUrl: "www.bs.com",
        accessToken: "token 1234",
      };
      expect(redisValueToUser(redisHValue)).to.deep.eq({
        username: "confidenceman02",
        userId: 1234,
        avatarUrl: "www.bs.com",
        accessToken: "token 1234",
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
});
