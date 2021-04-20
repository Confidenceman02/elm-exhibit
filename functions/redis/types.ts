import { Commands, Multi, RedisClient } from "redis";

export type DBTag = PermanentDBTag | ExpirableDBTag;

export enum PermanentDBTag {
  User,
  Exhibit,
}

export enum ExpirableDBTag {
  TempSession,
  Session,
}

export type Seconds = number;

export interface IPromisifiedRedis extends RedisClient {
  [x: string]: any;
}

export interface IPromisifiedRedisMulti extends Multi {
  [x: string]: any;
}

export interface TempSession {
  sessionId: string;
  referer: string;
}
