import examples from "../data/examples.json";
import {APIGatewayEvent, Context} from 'aws-lambda';
import { StatusCodes } from "http-status-codes";

type ErrorTag  = "AuthorNotFound" | "PackageNotFound" | "AuthorAndPackageNotFound" | "KeineAhnung"

interface ErrorBody
  {
    statusCode: StatusCodes;
    body: string;
  }

export async function handler(event: APIGatewayEvent, context: Context) {
  const params = event.queryStringParameters;

  if (!params) {
    return errorResponse(StatusCodes.BAD_REQUEST, "KeineAhnung" )
  }

  if (params.author && params.package) {
    return {
      statusCode: StatusCodes.OK,
      body: JSON.stringify({examples: examples}),
      headers: {
        "Content-Type": "application/json"
      }
    }
  } else {
    return errorResponse(StatusCodes.BAD_REQUEST, "KeineAhnung")
  }
}

function errorResponse(statusCode: StatusCodes, tag: ErrorTag): ErrorBody {
  return {
    statusCode: statusCode,
    body: JSON.stringify({ tag: tag })
  }
}