import {RedisClient} from "redis";

export enum DBTag {
  TempSession
}

export type Seconds = number

export interface IPromisifiedRedis extends RedisClient {
  [x:string]: any
}