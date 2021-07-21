import { Promise } from "bluebird";
import { createClient, RedisClient } from "redis";
import { IPromisifiedRedis, IPromisifiedRedisMulti } from "./types";
import { Result, ResultType } from "../../lib/result";
import { RedisClientInitError } from "../../lib/errors";

export const redisClientMulti: (
  cl: IPromisifiedRedis
) => IPromisifiedRedisMulti = (c: IPromisifiedRedis) => {
  return Promise.promisifyAll(c.MULTI());
};

const redisPort: string | undefined = process.env.REDIS_SERVICE_PORT;
const redisIP: string | undefined = process.env.REDIS_SERVICE_IP;
const redisPass: string | undefined = process.env.REDIS_PASSWORD;
const client: () => ResultType<IPromisifiedRedis> =
  (): ResultType<IPromisifiedRedis> => {
    if (redisIP && redisPort && redisPass) {
      const redisClient: RedisClient = createClient({
        host: redisIP,
        port: parseInt(redisPort),
        password: redisPass,
      });
      const redis = Promise.promisifyAll<IPromisifiedRedis>(redisClient);
      return Result<IPromisifiedRedis>().Ok(redis);
    }
    throw new RedisClientInitError("Redis client failed to initiate");
  };

export default client();
