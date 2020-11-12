import examples from "../data/examples.json";
import { APIGatewayEvent, Context } from 'aws-lambda';
import {errorResponse, noIdea, successResponse} from "./response";
import { ResponseBody } from "./types";

export async function handler(event: APIGatewayEvent, context: Context): Promise<ResponseBody> {
  const params = event.queryStringParameters;

  if (!params) {
    return errorResponse(noIdea)
  }

  if (params.author && params.package) {
    return successResponse({ tag: "ExamplesFetched", examples })
  } else {
    return errorResponse(noIdea)
  }
}
