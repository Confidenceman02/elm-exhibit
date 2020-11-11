import {DBTag, Seconds} from "./types";

export function generateDBKey(tag: DBTag, uniqueKey: string ): string {
  switch (tag) {
    case DBTag.TempSession:
      return `${uniqueKey}.tempsession`
    case DBTag.Session:
      return `${uniqueKey}.session`
  }
}

export function resolveExpiration(tag: DBTag): Seconds {
  switch (tag) {
    case DBTag.TempSession:
      return 300
    case DBTag.Session:
      return 604800
  }
}