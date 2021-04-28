import { Commands, Multi, RedisClient } from "redis";

export type DBTag = PermanentDBTag | ExpirableDBKey;

export enum PermanentDBTag {
  User,
  Exhibit,
}

export enum ExpirableDBKey {
  TempSession,
  Session,
  ElmPackages,
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
