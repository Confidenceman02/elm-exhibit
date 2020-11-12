import {generateDBKey, resolveExpiration} from "../../functions/redis/common";
import {expect} from "chai"
import {ExpirableDBTag, PermanentDBTag} from "../../functions/redis/types";

describe('generateDBKey', () => {
  context("TempSession", () => {
    it("should generate a temporary session key", () => {
      expect(generateDBKey(ExpirableDBTag.TempSession, "1234")).to.eq("1234.tempsession")
    })
  })
  context("Session", () => {
    it("should generate a session key", () => {
      expect(generateDBKey(ExpirableDBTag.TempSession, "1234")).to.eq("1234.session")
    })
  })
  context("User", () => {
    it("should generate a user key", () => {
      expect(generateDBKey(PermanentDBTag.User, "12345")).to.eq("12345.user")
    })
  })
})

describe('resolveExpiration', () => {
  context('TempSession', () => {
    it('returns the expiration', () => {
      expect(resolveExpiration(ExpirableDBTag.TempSession)).to.eq(300)
    })
  })
  context('Session', () => {
    it('returns the expiration', () => {
      expect(resolveExpiration(ExpirableDBTag.TempSession)).to.eq(604800)
    })
  })
})