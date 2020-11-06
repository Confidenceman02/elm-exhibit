import examples from "../data/examples.json";
import { APIGatewayEvent, Context } from 'aws-lambda';
import { StatusCodes } from "http-status-codes";
import {errorResponse, noIdea, successBody} from "./response";
import { ResponseBody } from "./types";

interface ErrorBody
  {
    statusCode: StatusCodes;
    body: string;
  }

export async function handler(event: APIGatewayEvent, context: Context): Promise<ResponseBody> {
  const params = event.queryStringParameters;

  if (!params) {
    return errorResponse(StatusCodes.BAD_REQUEST, noIdea )
  }

  if (params.author && params.package) {
    return successBody(StatusCodes.OK, { examples })
  } else {
    return errorResponse(StatusCodes.BAD_REQUEST, noIdea)
  }
}
