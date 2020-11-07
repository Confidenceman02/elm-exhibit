import {expect} from "chai";
import {errorResponse, noIdea} from "../functions/response";
import {ExampleErrorBody, SessionErrorBody} from "../functions/types";
import {StatusCodes} from "http-status-codes";

describe("errorResponse", () => {
  describe("ExampleErrorBody", () => {
    describe("ExampleBuildFailed", () => {
      const tag: ExampleErrorBody = { tag: "ExampleBuildFailed" }
      it("should return error response body", () => {
        const expected =
          {
            statusCode: StatusCodes.BAD_REQUEST,
            body: JSON.stringify(tag),
            headers: {"Content-Type": "application/json"}
          }
        expect(errorResponse(tag)).to.deep.eq(expected)
      });
    })
    describe("AuthorNotFound", () => {
      const tag: ExampleErrorBody = { tag: "AuthorNotFound", foundAuthor: "Some Author"}
      it("should return error response body", () => {
        const expected =
          {
            statusCode: StatusCodes.NOT_FOUND,
            body: JSON.stringify(tag),
            headers: {"Content-Type": "application/json"}
          }
        expect(errorResponse(tag)).to.deep.eq(expected)
      })
    })
    describe("PackageNotFound", () => {
      const tag: ExampleErrorBody = { tag: "PackageNotFound" }
      it("should return error response body", () => {
        const expected =
          {
            statusCode: StatusCodes.NOT_FOUND,
            body: JSON.stringify(tag),
            headers: {"Content-Type": "application/json"}
          }
        expect(errorResponse(tag)).to.deep.eq(expected)
      })
    })
    describe("AuthorAndPackageNotFound", () => {
      const tag: ExampleErrorBody = { tag: "AuthorAndPackageNotFound" }
      it("should return error response body", () => {
        const expected =
            {
              statusCode: StatusCodes.NOT_FOUND,
              body: JSON.stringify(tag),
              headers: {"Content-Type": "application/json"}
            }
        expect(errorResponse(tag)).to.deep.eq(expected)
      })
    })
    describe("KaineAhnung", () => {
      const tag: ExampleErrorBody = { tag: "KeineAhnung" }
      it("should return error response body", () => {
        const expected =
            {
              statusCode: StatusCodes.BAD_REQUEST,
              body: JSON.stringify(tag),
              headers: {"Content-Type": "application/json"}
            }
        expect(errorResponse(tag)).to.deep.eq(expected)
      })
    })
  })
  describe("SessionErrorBody", () => {
    describe("RefreshFailed", () => {
      const tag: SessionErrorBody = { tag: "RefreshFailed" }
      it("should return error response body", () => {
        const expected =
          {
            statusCode: StatusCodes.NOT_FOUND,
            body: JSON.stringify(tag),
            headers: {"Content-Type": "application/json"}
          }
        expect(errorResponse(tag)).to.deep.eq(expected)
      })
    })
    describe("LoginFailed", () => {
      const tag: SessionErrorBody = { tag: "LogInFailed" }
      it("should return error response body", () => {
        const expected =
            {
              statusCode: StatusCodes.INTERNAL_SERVER_ERROR,
              body: JSON.stringify(tag),
              headers: {"Content-Type": "application/json"}
            }
        expect(errorResponse(tag)).to.deep.eq(expected)
      })
    })
  })
})