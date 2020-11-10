import { StatusCodes } from "http-status-codes";
import { APIGatewayEvent, Context } from "aws-lambda";
import { ResponseBody } from "./types";
import { errorResponse } from "./response";
import { jsonHeaders} from "./headers";

export async function handler(event: APIGatewayEvent, context: Context): Promise<ResponseBody> {
  const { cookie } = event.headers

  if (cookie) {
    return {
      statusCode: StatusCodes.OK,
      body: JSON.stringify({name: "Jaime", id: "123", tag: "SessionRefreshed"}),
      headers: { ...jsonHeaders }
    }
  } else {
    return errorResponse({ tag: "RefreshFailed" })
  }
}