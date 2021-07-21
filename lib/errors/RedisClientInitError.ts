export class RedisClientInitError extends Error {
  constructor(...params: any[]) {
    super(...params);
    Object.setPrototypeOf(this, RedisClientInitError.prototype);
    if (Error.captureStackTrace) {
      Error.captureStackTrace(this, RedisClientInitError);
    }
    this.name = "RedisClientInitError";
  }
}
