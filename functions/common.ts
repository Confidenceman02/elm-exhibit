import { ElmLangPackage } from "./types";

export function removeWhiteSpace(value: string): string {
  return value.replace(/\s/g, "");
}

export function elmLangPackagesToAuthor(
  author: string,
  packages: ElmLangPackage[]
): ElmLangPackage[] {
  const filteredPackages: ElmLangPackage[] = packages.filter((p) => {
    const packageAuthorSubString: string = p.name.substring(
      0,
      p.name.lastIndexOf("/")
    );
    return packageAuthorSubString === author;
  });
  return filteredPackages;
}
