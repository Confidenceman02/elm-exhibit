import { Promise } from "bluebird";
import { createClient, RedisClient } from "redis";
import { IPromisifiedRedis } from "./types";
import { Result, ResultType } from "../../lib/result";

const redisPort: string | undefined = process.env.REDIS_SERVICE_PORT;
const redisIP: string | undefined = process.env.REDIS_SERVICE_IP;
const client: () => ResultType<IPromisifiedRedis> = (): ResultType<IPromisifiedRedis> => {
  if (redisIP && redisPort) {
    const redisClient: RedisClient = createClient({
      host: redisIP,
      port: parseInt(redisPort),
    });
    const redis = Promise.promisifyAll<IPromisifiedRedis>(redisClient);
    return Result<IPromisifiedRedis>().Ok(redis);
  }
  return Result().Err;
};

export default client();
