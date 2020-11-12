import {DBTag, ExpirableDBTag, PermanentDBTag, Seconds} from "./types";

export function generateExpirableDBKey(tag: ExpirableDBTag, uniqueKey: string ): string {
  switch (tag) {
    case ExpirableDBTag.TempSession:
      return `${uniqueKey}.tempsession`
    case ExpirableDBTag.Session:
      return `${uniqueKey}.session`
  }
}

export function generatePermanentDBKey(tag: PermanentDBTag, uniqueKey: string): string {
  switch (tag) {
    case PermanentDBTag.User:
      return `${uniqueKey}.user`
  }
}

export function resolveExpiration(tag: ExpirableDBTag): Seconds {
  switch (tag) {
    case ExpirableDBTag.TempSession:
      return 300
    case ExpirableDBTag.Session:
      return 604800
  }
}