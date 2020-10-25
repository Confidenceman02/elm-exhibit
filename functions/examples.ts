import examples from "../data/examples.json";
import { APIGatewayEvent, Context } from 'aws-lambda';
import { StatusCodes } from "http-status-codes";
import { errorResponse } from "./common";
import { ResponseBody } from "./types";

interface ErrorBody
  {
    statusCode: StatusCodes;
    body: string;
  }

export async function handler(event: APIGatewayEvent, context: Context): Promise<ResponseBody> {
  const params = event.queryStringParameters;

  if (!params) {
    return errorResponse(StatusCodes.BAD_REQUEST, { tag: "KeineAhnung" } )
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
    return errorResponse(StatusCodes.BAD_REQUEST, { tag: "KeineAhnung" })
  }
}