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

export const Table = { users: "users", exhibits: "exhibits" };

export function redisUserToUser(
  redisReturnValue: RedisReturnType<RedisHValue<User>>
): ResultType<User> {
  if (redisReturnValue !== null) {
    return Result<User>().Ok({
      username: redisReturnValue.username,
      userId: parseInt(redisReturnValue.userId),
      avatarUrl: redisReturnValue.avatarUrl,
      accessToken: redisReturnValue.accessToken,
    });
  }
  return Result().Err;
}

export function redisUserSessionUserSession(
  redisReturnValue: RedisReturnType<RedisHValue<UserSession>>
): ResultType<UserSession> {
  if (redisReturnValue !== null) {
    return Result<UserSession>().Ok({
      username: redisReturnValue.username,
      userId: parseInt(redisReturnValue.userId),
      avatarUrl: redisReturnValue.avatarUrl,
      sessionId: redisReturnValue.sessionId,
    });
  }
  return Result().Err;
}

export function redisUserIdToUserId(
  redisValue: RedisReturnType<string>
): ResultType<number> {
  if (redisValue !== null) {
    const parsedId = parseInt(redisValue);
    if (typeof parsedId !== "number" || parsedId !== Number(parsedId)) {
      return Result<null>().Err;
    }
    return Result<number>().Ok(parsedId);
  }
  return Result().Err;
}

export function redisValueToValueResult<T>(
  redisValue: RedisReturnType<T>
): ResultType<T> {
  if (redisValue !== null) {
    return Result<T>().Ok(redisValue);
  }
  return Result().Err;
}
