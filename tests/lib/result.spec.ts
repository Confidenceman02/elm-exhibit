import { expect } from "chai";
import { Result, Status } from "../../lib/result";

describe("Result", () => {
  describe("Err", () => {
    it("should return Err result", () => {
      expect(Result().Err).to.deep.eq({ Status: Status.Err });
    });
  });
  describe("Ok", () => {
    it("should return Ok result", () => {
      expect(Result().Ok("something")).to.deep.eq({
        Status: Status.Ok,
        data: "something",
      });
    });
  });
});
