import { StatusCodes } from "http-status-codes";
import { APIGatewayEvent, Context } from "aws-lambda";
import {errorResponse, noIdea} from "./response";
import { ResponseBody } from "./types";
import redisClient from "./redis/client"

export async function handler(event: APIGatewayEvent, context: Context): Promise<ResponseBody> {
  const params = event.queryStringParameters;

  if (!params) {
    return errorResponse(noIdea )
  }

  if (params.author && params.package && params.example) {
    const val = await redisClient.GETAsync("hello")
    if (val) {
      // temporary html resolving. Real html will come from elm compiler.
      // const htmlString = await fs.readFile(path.resolve(process.cwd(),'data/elm.js'), "utf-8")
      // get rid of all the new line characters etc.
      // const minifiedHtml: string = htmlString.toString();

      return {
        statusCode: StatusCodes.OK,
        body: "WORKED",
        headers: {
          "Content-Type": "text/javascript"
        }
      }
    }
    return {
      statusCode: StatusCodes.INTERNAL_SERVER_ERROR,
      body: "NOVALUESON",
      headers: {
        "Content-Type": "application/json"
      }
    }
  }
  return errorResponse(noIdea)
}
