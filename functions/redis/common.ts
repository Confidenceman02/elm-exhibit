import {DBTag, Seconds} from "./types";

export function generateDBKey(tag: DBTag, uniqueKey: string ): string {
  switch (tag) {
    case DBTag.TempSession:
      return `${uniqueKey}.tempsession`
  }
}

export function resolveExpiration(tag: DBTag): Seconds {
  switch (tag) {
    case DBTag.TempSession:
      return 300
  }
}