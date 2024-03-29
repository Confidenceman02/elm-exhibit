import {
  generateElmPackagesCacheKey,
  generateExhibitKey,
  generateSessionKey,
  generateTempSessionKey,
  generateUserKey,
  resolveExpiration,
} from "../../functions/redis/common";
import { expect } from "chai";
import { ExpirableDBKey, PermanentDBTag } from "../../functions/redis/types";

describe("generateUserKey", () => {
  it("should generate a user key", () => {
    expect(generateUserKey(12345)).to.eq("12345.user");
  });
});

describe("generateExhibitKey", () => {
  it("generate exhibit keyp", () => {
    expect(
      generateExhibitKey(
        "Confidenceman02",
        "Confidenceman02/elm-animate-height"
      )
    ).to.eq("Confidenceman02.Confidenceman02/elm-animate-height.exhibit");
  });
});

describe("generateSessionKey", () => {
  it("generate session key", () => {
    expect(generateSessionKey("12-34")).to.eq("12-34.session");
  });
});

describe("generateTempSessionKey", () => {
  it("generate temporary session key", () => {
    expect(generateTempSessionKey("12-34")).to.eq("12-34.tempSession");
  });
});

describe("resolveExpiration", () => {
  context("TempSession", () => {
    it("returns the expiration", () => {
      expect(resolveExpiration(ExpirableDBKey.TempSession)).to.eq(300);
    });
  });
  context("Session", () => {
    it("returns the expiration", () => {
      expect(resolveExpiration(ExpirableDBKey.Session)).to.eq(604800);
    });
  });
  context("ElmPackages", () => {
    it("returns the expiration", () => {
      expect(resolveExpiration(ExpirableDBKey.ElmPackages)).to.eq(600);
    });
  });
});

describe("generateElmPackagesCacheKey", () => {
  it("returns a elm packages cache key", () => {
    expect(generateElmPackagesCacheKey()).to.eq("elmLangPackages.cache");
  });
});
