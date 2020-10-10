import examples from "../data/examples.json";
import {APIGatewayEvent, Context} from 'aws-lambda';
import { StatusCodes } from "http-status-codes";

export async function handler(event: APIGatewayEvent, context: Context) {
  const params = event.queryStringParameters;

  if (!params) {
    return errorResponse(StatusCodes.BAD_REQUEST, "Missing author and package parameters" )
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
    return errorResponse(StatusCodes.BAD_REQUEST, "Missing author and package parameters")
  }
}

function errorResponse(statusCode: StatusCodes, errMsg: string) {
  return {
    statusCode: statusCode,
    body: { error: errMsg }
  }
}