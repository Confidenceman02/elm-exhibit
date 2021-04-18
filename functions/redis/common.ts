import { ExpirableDBTag, PermanentDBTag, Seconds } from "./types";

function generateExpirableDBKey(
  tag: ExpirableDBTag,
  uniqueKey: string
): string {
  switch (tag) {
    case ExpirableDBTag.TempSession:
      return `${uniqueKey}.tempSession`;
    case ExpirableDBTag.Session:
      return `${uniqueKey}.session`;
  }
}

function generatePermanentDBKey(
  tag: PermanentDBTag,
  uniqueKey: string
): string {
  switch (tag) {
    case PermanentDBTag.User:
      return `${uniqueKey}.user`;
    case PermanentDBTag.Exhibit:
      return `${uniqueKey}.exhibit`;
  }
}

export function generateSessionKey(uniqueKey: string) {
  return generateExpirableDBKey(ExpirableDBTag.Session, uniqueKey);
}

export function generateTempSessionKey(uniqueKey: string) {
  return generateExpirableDBKey(ExpirableDBTag.TempSession, uniqueKey);
}

export function generateExhibitKey(
  userName: string,
  exhibitName: string
): string {
  return generatePermanentDBKey(
    PermanentDBTag.Exhibit,
    `${userName}.${exhibitName}`
  );
}

export function generateUserKey(userId: number) {
  return generatePermanentDBKey(PermanentDBTag.User, userId.toString());
}

export function resolveExpiration(tag: ExpirableDBTag): Seconds {
  switch (tag) {
    case ExpirableDBTag.TempSession:
      return 300;
    case ExpirableDBTag.Session:
      return 604800;
  }
}
