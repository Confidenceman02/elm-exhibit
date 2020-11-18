import {expect} from "chai";
import {errorResponse, successResponse} from "../functions/response";
import {ExampleErrorBody, ExampleSuccessBody, SessionErrorBody, SessionSuccessBody} from "../functions/types";
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
              statusCode: StatusCodes.INTERNAL_SERVER_ERROR,
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

describe("successBody", () => {
  describe("ExamplesFetched", () => {
    const tag: ExampleSuccessBody = {
      tag: "ExamplesFetched",
      examples: [{ id: "123", name: "some name", description: "some description" }]
    }
    it("should return success response", () => {
      const expected = {
        statusCode: StatusCodes.OK,
        body: JSON.stringify(tag),
        headers: {"Content-Type": "application/json"}
      }
      expect(successResponse(tag)).to.deep.eq(expected)
    })
  })
  describe("SessionRefreshed", () => {
    const tag: SessionSuccessBody = { tag: "SessionRefreshed" }
    it("should return success response", () => {
      const expected = {
        statusCode: StatusCodes.OK,
        body: JSON.stringify(tag),
        headers: {"Content-Type": "application/json"}
      }
      expect(successResponse(tag)).to.deep.eq(expected)
    })
  })
  describe("Redirecting", () => {
    const tag: SessionSuccessBody = { tag: "Redirecting", location: "www.bs.com" }
    it('should return a success response', () => {
      const expected = {
        statusCode: StatusCodes.OK,
        body: JSON.stringify(tag),
        headers: {"Content-Type": "application/json"}
      }
      expect(successResponse(tag)).to.deep.eq(expected)
    });
  })
  describe("SessionGranted", () => {
    const tag: SessionSuccessBody = {
      tag: "SessionGranted",
      session: { username: "confidenceman02", avatarUrl: "www.avatarurl.com", userId: 1234, sessionId: "S1234" }}
    it("should return a success response", () => {
      const expected = {
        statusCode: StatusCodes.OK,
        body: JSON.stringify(tag),
        headers: {
          "Content-Type": "application/json",
          "Set-Cookie": "session_id=S1234; HttpOnly"
        }
      }
      expect(successResponse(tag)).to.deep.eq(expected)
    })
  })
})