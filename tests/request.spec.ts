import {parseCookie} from "../functions/request";
import {expect} from "chai"
import {Status} from "../lib/result";

describe.only("parseCookie", () => {
  describe("when there is a valid cookie", () => {
    const cookie = "session_id=12345;"
    it("returns a cookie object", () => {
      expect(parseCookie(cookie)).to.deep.eq({Status: Status.Ok, data: {session_id: '12345'}})
    })
  })
  describe("when there is an invalid cookie", () => {
    const cookie = "session_idsss=12345;"
    it("returns error result", () => {
      expect(parseCookie(cookie)).to.deep.eq({Status: Status.Err})
    })
  })
  describe("when there is no cookie", () => {
    it("returns error result", () => {
      expect(parseCookie(undefined)).to.deep.eq({Status: Status.Err})
    })
  })
})