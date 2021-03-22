export const UserSchemaKey = {
  username: "username",
  userId: "userId",
  avatarUrl: "avatarUrl",
};

export interface User {
  username: string;
  userId: number;
  avatarUrl: string;
}

export type UserSession = {
  username: string;
  userId: number;
  avatarUrl: string;
  sessionId: string;
};

export type RedisHValue<T> = {
  [P in keyof T]: string;
};

export const Table = { users: "users" };

export function redisValueToUser(redisValue: RedisHValue<User>): User {
  return {
    username: redisValue.username,
    userId: parseInt(redisValue.userId),
    avatarUrl: redisValue.avatarUrl,
  };
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
