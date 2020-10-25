import { APIGatewayEvent, Context } from "aws-lambda";
import { RedirectBody } from "./types";
import { StatusCodes } from "http-status-codes";

export async function handler(event: APIGatewayEvent, context: Context): Promise<RedirectBody> {
  return {
    statusCode: StatusCodes.SEE_OTHER,
    headers: {
     "Location": "www.google.com"
    }
  }
}
