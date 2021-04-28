import { expect } from "chai";
import { errorResponse, successResponse } from "../functions/response";
import {
  AuthorExhibitsErrorBody,
  AuthorExhibitsSuccessBody,
  ExampleErrorBody,
  ExampleSuccessBody,
  SessionErrorBody,
  SessionSuccessBody,
} from "../functions/types";
import { StatusCodes } from "http-status-codes";

describe("errorResponse", () => {
  describe("ExampleErrorBody", () => {
    describe("AuthorNotFound", () => {
      const tag: ExampleErrorBody = {
        tag: "AuthorNotFound",
      };
      it("should return error response body", () => {
        const expected = {
          statusCode: StatusCodes.NOT_FOUND,
          body: JSON.stringify(tag),
          headers: { "Content-Type": "application/json" },
        };
        expect(errorResponse(tag)).to.deep.eq(expected);
      });
    });
    describe("PackageNotFound", () => {
      const tag: ExampleErrorBody = { tag: "ExhibitNotFound" };
      it("should return error response body", () => {
        const expected = {
          statusCode: StatusCodes.NOT_FOUND,
          body: JSON.stringify(tag),
          headers: { "Content-Type": "application/json" },
        };
        expect(errorResponse(tag)).to.deep.eq(expected);
      });
    });
    describe("AuthorAndPackageNotFound", () => {
      const tag: ExampleErrorBody = { tag: "AuthorAndExhibitNotFound" };
      it("should return error response body", () => {
        const expected = {
          statusCode: StatusCodes.NOT_FOUND,
          body: JSON.stringify(tag),
          headers: { "Content-Type": "application/json" },
        };
        expect(errorResponse(tag)).to.deep.eq(expected);
      });
    });
    describe("KaineAhnung", () => {
      const tag: ExampleErrorBody = { tag: "KeineAhnung" };
      it("should return error response body", () => {
        const expected = {
          statusCode: StatusCodes.INTERNAL_SERVER_ERROR,
          body: JSON.stringify(tag),
          headers: { "Content-Type": "application/json" },
        };
        expect(errorResponse(tag)).to.deep.eq(expected);
      });
    });
  });

  describe("SessionErrorBody", () => {
    describe("RefreshFailed", () => {
      const tag: SessionErrorBody = { tag: "RefreshFailed" };
      it("should return error response body", () => {
        const expected = {
          statusCode: StatusCodes.NOT_FOUND,
          body: JSON.stringify(tag),
          headers: { "Content-Type": "application/json" },
        };
        expect(errorResponse(tag)).to.deep.eq(expected);
      });
    });
    describe("LoginFailed", () => {
      const tag: SessionErrorBody = { tag: "LoginFailed" };
      it("should return error response body", () => {
        const expected = {
          statusCode: StatusCodes.INTERNAL_SERVER_ERROR,
          body: JSON.stringify(tag),
          headers: { "Content-Type": "application/json" },
        };
        expect(errorResponse(tag)).to.deep.eq(expected);
      });
    });
    describe("SessionNotFound", () => {
      const tag: SessionErrorBody = { tag: "SessionNotFound" };

      it("should return error response body", () => {
        const expected = {
          statusCode: StatusCodes.NOT_FOUND,
          body: JSON.stringify(tag),
          headers: { "Content-Type": "application/json" },
        };
        expect(errorResponse(tag)).to.deep.eq(expected);
      });
    });
    describe("MissingCookie", () => {
      const tag: SessionErrorBody = { tag: "MissingCookie" };

      it("should return error response body", () => {
        const expected = {
          statusCode: StatusCodes.BAD_REQUEST,
          body: JSON.stringify(tag),
          headers: { "Content-Type": "application/json" },
        };

        expect(errorResponse(tag)).to.deep.eq(expected);
      });
    });
  });
});

describe("AuthorExhibitsErrorBody", () => {
  it("AuthorNotFound should return NOT_FOUND", () => {
    const tag: AuthorExhibitsErrorBody = { tag: "AuthorNotFound" };
    const expected = {
      statusCode: StatusCodes.NOT_FOUND,
      body: JSON.stringify(tag),
      headers: { "Content-Type": "application/json" },
    };

    expect(errorResponse(tag)).to.deep.eq(expected);
  });

  it("AuthorNotFoundWithElmLangPackages should return NOT_FOUND", () => {
    const tag: AuthorExhibitsErrorBody = {
      tag: "AuthorNotFoundWithElmLangPackages",
      packages: [{ name: "Confidenceman02/elm-animate-height" }],
    };
    const expected = {
      statusCode: StatusCodes.NOT_FOUND,
      body: JSON.stringify(tag),
      headers: { "Content-Type": "application/json" },
    };

    expect(errorResponse(tag)).to.deep.eq(expected);
  });

  it("MissingAuthorParam should return BAD_REQUEST", () => {
    const tag: AuthorExhibitsErrorBody = { tag: "MissingAuthorParam" };
    const expected = {
      statusCode: StatusCodes.BAD_REQUEST,
      body: JSON.stringify(tag),
      headers: { "Content-Type": "application/json" },
    };

    expect(errorResponse(tag)).to.deep.eq(expected);
  });
});

describe("AuthorExhibitsSuccessBody", () => {
  it("should return OK", () => {
    const tag: AuthorExhibitsSuccessBody = {
      tag: "AuthorExhibitsFetched",
      exhibits: [],
    };

    const expected = {
      statusCode: StatusCodes.OK,
      body: JSON.stringify(tag),
      headers: { "Content-Type": "application/json" },
    };

    expect(successResponse(tag)).to.deep.eq(expected);
  });
});

describe("ExampleSuccessBody", () => {
  describe("ExamplesFetched", () => {
    const tag: ExampleSuccessBody = {
      tag: "ExamplesFetched",
      examples: [
        { id: "123", name: "some name", description: "some description" },
      ],
    };
    it("should return success response", () => {
      const expected = {
        statusCode: StatusCodes.OK,
        body: JSON.stringify(tag),
        headers: { "Content-Type": "application/json" },
      };
      expect(successResponse(tag)).to.deep.eq(expected);
    });
  });
  describe("SessionRefreshed", () => {
    const tag: SessionSuccessBody = {
      tag: "SessionRefreshed",
      session: {
        username: "confidenceman02",
        avatarUrl: "www.avatarurl.com",
        userId: 1234,
        sessionId: "S1234",
      },
    };
    it("should return success response", () => {
      const expected = {
        statusCode: StatusCodes.OK,
        body: JSON.stringify(tag),
        headers: { "Content-Type": "application/json" },
      };
      expect(successResponse(tag)).to.deep.eq(expected);
    });
  });
  describe("Redirecting", () => {
    const tag: SessionSuccessBody = {
      tag: "Redirecting",
      location: "www.bs.com",
    };
    it("should return a success response", () => {
      const expected = {
        statusCode: StatusCodes.OK,
        body: JSON.stringify(tag),
        headers: { "Content-Type": "application/json" },
      };
      expect(successResponse(tag)).to.deep.eq(expected);
    });
  });
  describe("SessionGranted", () => {
    const tag: SessionSuccessBody = {
      tag: "SessionGranted",
      session: {
        username: "confidenceman02",
        avatarUrl: "www.avatarurl.com",
        userId: 1234,
        sessionId: "S1234",
      },
    };
    it("should return a success response", () => {
      const expected = {
        statusCode: StatusCodes.OK,
        body: JSON.stringify(tag),
        headers: {
          "Content-Type": "application/json",
          "Set-Cookie": "session_id=S1234; HttpOnly",
        },
      };
      expect(successResponse(tag)).to.deep.eq(expected);
    });
  });
  describe("SessionDestroyed", () => {
    const tag: SessionSuccessBody = { tag: "SessionDestroyed" };
    it("should return a success response with expired headers", () => {
      const expected = {
        statusCode: StatusCodes.OK,
        body: JSON.stringify(tag),
        headers: {
          "Content-Type": "application/json",
          "Set-Cookie": 'session_id=""; Max-Age=0 HttpOnly',
        },
      };
      expect(successResponse(tag)).to.deep.eq(expected);
    });
  });
});
