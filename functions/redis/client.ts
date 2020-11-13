import {Promise} from "bluebird";
import redisLib from "redis";
import {IPromisifiedRedis} from "./types";
import {Result, ResultType} from "../../lib/result";

const redisPort: string | undefined = process.env.REDIS_SERVICE_PORT ? process.env.REDIS_SERVICE_PORT : "0"
const redisIP: string | undefined = process.env.REDIS_SERVICE_IP
const redis = Promise.promisifyAll(redisLib)
const client: () => ResultType<IPromisifiedRedis> = (): ResultType<IPromisifiedRedis> => {
  if (redisIP && redisPort) {
    const redisClient = redis.createClient({
      host: redisIP,
      port: parseInt(redisPort)
    })
    return Result<IPromisifiedRedis>().Ok(redisClient)
  }
  return Result().Err
}

export default client()
