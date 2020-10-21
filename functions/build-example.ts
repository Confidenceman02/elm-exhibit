import { StatusCodes } from "http-status-codes";
import { APIGatewayEvent, Context } from "aws-lambda";
import {errorResponse, removeWhiteSpace} from "./common";
import { promises as fs } from "fs";
import { Promise } from "bluebird";
import path from "path";
import { minify } from "html-minifier";
import { ResponseBody } from "./types";
import redisLib from "redis";

const redisPort = process.env.REDIS_SERVICE_PORT ? process.env.REDIS_SERVICE_PORT : "0"

const redis = Promise.promisifyAll(redisLib)
const client = redis.createClient({
  host: process.env.REDIS_SERVICE_IP,
  port: parseInt(redisPort)
})

function getCacheKey(author: string, pkg: string, example: string): string {
  return removeWhiteSpace(`${author}-${pkg}-${example}-compiled`)
}

export async function handler(event: APIGatewayEvent, context: Context): Promise<ResponseBody> {
  const params = event.queryStringParameters;

  if (!params) {
    return errorResponse(StatusCodes.BAD_REQUEST, { tag: "KeineAhnung" } )
  }

  client.on("error", (e) => {
    return errorResponse(StatusCodes.BAD_REQUEST, { tag: "KeineAhnung" } )
  })


  if (params.author && params.package && params.example) {
    const val = await client.get("happy")

    if (val) {
      // temporary html resolving. Real html will come from elm compiler.
      // const htmlString = await fs.readFile(path.resolve(process.cwd(),'data/elm.js'), "utf-8")
      // get rid of all the new line characters etc.
      // const minifiedHtml: string = htmlString.toString();

      return {
        statusCode: StatusCodes.OK,
        body: "WORKEDJ",
        headers: {
          "Content-Type": "text/javascript"
        }
      }
    }
    return {
      statusCode: StatusCodes.INTERNAL_SERVER_ERROR,
      body: "NOVALUESON",
      headers: {
        "Content-Type": "text/javascript"
      }
    }
  }
  return errorResponse(StatusCodes.BAD_REQUEST, { tag: "KeineAhnung" })
}
