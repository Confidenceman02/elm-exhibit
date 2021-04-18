import { Result, ResultType } from "../../lib/result";

export const UserSchemaKey = {
  username: "username",
  userId: "userId",
  avatarUrl: "avatarUrl",
  accessToken: "accessToken",
};

export interface User {
  username: string;
  userId: number;
  avatarUrl: string;
  accessToken: string;
}

export type UserSession = {
  username: string;
  userId: number;
  avatarUrl: string;
  sessionId: string;
};

export type RedisReturnType<T> = null | T;

// all H values in redis return as a string
export type RedisHValue<T> = {
  [P in keyof T]: string;
};

export const Table = { users: "users" };

export function redisReturnValueToUser(
  redisReturnValue: RedisReturnType<RedisHValue<User>>
): ResultType<User> {
  if (redisReturnValue != null) {
    return Result<User>().Ok({
      username: redisReturnValue.username,
      userId: parseInt(redisReturnValue.userId),
      avatarUrl: redisReturnValue.avatarUrl,
      accessToken: redisReturnValue.accessToken,
    });
  }
  return Result<User>().Err;
}

export function redisValueToUserSession(
  redisValue: RedisHValue<UserSession>
): UserSession {
  return {
    username: redisValue.username,
    userId: parseInt(redisValue.userId),
    avatarUrl: redisValue.avatarUrl,
    sessionId: redisValue.sessionId,
  };
}
