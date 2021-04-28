import { ExpirableDBKey, PermanentDBTag, Seconds } from "./types";
import { Table } from "./schema";

function generateExpirableDBKey(
  key: ExpirableDBKey,
  uniqueKey: string
): string {
  switch (key) {
    case ExpirableDBKey.TempSession:
      return `${uniqueKey}.tempSession`;
    case ExpirableDBKey.Session:
      return `${uniqueKey}.session`;
    case ExpirableDBKey.ElmPackages:
      return `${uniqueKey}.cache`;
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

export function generateElmPackagesCacheKey() {
  return generateExpirableDBKey(
    ExpirableDBKey.ElmPackages,
    Table.elmLangPackages
  );
}

export function generateSessionKey(uniqueKey: string) {
  return generateExpirableDBKey(ExpirableDBKey.Session, uniqueKey);
}

export function generateTempSessionKey(uniqueKey: string) {
  return generateExpirableDBKey(ExpirableDBKey.TempSession, uniqueKey);
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

export function resolveExpiration(tag: ExpirableDBKey): Seconds {
  switch (tag) {
    case ExpirableDBKey.TempSession:
      return 300;
    case ExpirableDBKey.Session:
      return 604800;
    case ExpirableDBKey.ElmPackages:
      return 600;
  }
}
