import {Promise} from "bluebird";
import redisLib from "redis";
import {IPromisifiedRedis} from "./types";

const redisPort = process.env.REDIS_SERVICE_PORT ? process.env.REDIS_SERVICE_PORT : "0"
const redis = Promise.promisifyAll(redisLib)
const client: IPromisifiedRedis = redis.createClient({
  host: process.env.REDIS_SERVICE_IP,
  port: parseInt(redisPort)
})

export default client
