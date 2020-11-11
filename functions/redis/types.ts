import {RedisClient} from "redis";

export enum DBTag {
  TempSession,
  Session
}

export type Seconds = number

export interface IPromisifiedRedis extends RedisClient {
  [x:string]: any
}

export interface TempSessionMeta
  {
    sessionId: string,
    referer: string
  }
