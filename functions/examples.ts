import examples from "../data/examples.json";

import { APIGatewayEvent, Context } from "aws-lambda";
import { errorResponse, noIdea, successResponse } from "./response";
import { Example, ResponseBody } from "./types";

async function handleMockedExamples(): Promise<Example[]> {
  let examplesList: Example[] = [];
  const resolveExamples = new Promise((resolve) => {
    setTimeout(() => {
      examplesList = examples;
      resolve(null);
    }, 1000);
  });
  await resolveExamples;
  return examplesList;
}

export async function handler(
  event: APIGatewayEvent,
  context: Context
): Promise<ResponseBody> {
  const params = event.queryStringParameters;

  if (!params) {
    return errorResponse(noIdea);
  }

  if (params.author && params.package) {
    const getExamples = await handleMockedExamples();
    return successResponse({ tag: "ExamplesFetched", examples: getExamples });
  } else {
    return errorResponse(noIdea);
  }
}
