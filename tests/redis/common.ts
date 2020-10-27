import {generateDBKey, resolveExpiration} from "../../functions/redis/common";
import {expect} from "chai"
import {DBTag} from "../../functions/redis/types";

describe('generateDBKey', () => {
  context("TempSession", () => {
    it("should generate a temporary session key", () => {
      expect(generateDBKey(DBTag.TempSession, "1234")).to.eq("1234.tempsession")
    })
  })
})

describe('resolveExpiration', () => {
  context('TempSession', () => {
    it('returns the expiration', () => {
      expect(resolveExpiration(DBTag.TempSession)).to.eq(300)
    })
  })
})