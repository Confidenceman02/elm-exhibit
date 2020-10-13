import examples from "../data/examples.json";
import {APIGatewayEvent, Context} from 'aws-lambda';
import { StatusCodes } from "http-status-codes";

type ErrorTag  =
  { tag: "ExampleBuildFailed" }
  | { tag: "AuthorNotFound", foundAuthor: string }
  | { tag: "PackageNotFound" }
  | { tag: "AuthorAndPackageNotFound" }
  | { tag: "KeineAhnung" }

interface ErrorBody
  {
    statusCode: StatusCodes;
    body: string;
  }

export async function handler(event: APIGatewayEvent, context: Context) {
  const params = event.queryStringParameters;

  if (!params) {
    return errorResponse(StatusCodes.BAD_REQUEST, { tag: "KeineAhnung" } )
  }

  if (params.author && params.package) {
    return errorResponse(StatusCodes.BAD_REQUEST, { tag: "AuthorNotFound", foundAuthor: "Confidenceman03" } )
    // return {
    //   statusCode: StatusCodes.OK,
    //   body: JSON.stringify({examples: examples}),
    //   headers: {
    //     "Content-Type": "application/json"
    //   }
    // }
  } else {
    return errorResponse(StatusCodes.BAD_REQUEST, { tag: "KeineAhnung" })
  }
}

function errorResponse(statusCode: StatusCodes, error: ErrorTag): ErrorBody {
  return {
    statusCode: statusCode,
    body: JSON.stringify(error)
  }
}