import { StatusCodes } from "http-status-codes";
import { APIGatewayEvent, Context } from "aws-lambda";
import { errorResponse } from "./common";
import { promises as fs } from "fs";
import path from "path";
import { minify } from "html-minifier";
import { ResponseBody } from "./types";

export async function handler(event: APIGatewayEvent, context: Context): Promise<ResponseBody> {
  const params = event.queryStringParameters;

  if (!params) {
    return errorResponse(StatusCodes.BAD_REQUEST, { tag: "KeineAhnung" } )
  }

  if (params.author && params.package && params.example) {
    try {
      // temporary html resolving. Real html will come from elm compiler.
      const htmlString = await fs.readFile(path.resolve(process.cwd(),'data/basic.html'), "utf-8")
      // get rid of all the new line characters etc.
      const minifiedHtml: string = minify(htmlString.toString(), {quoteCharacter: "'", preserveLineBreaks: false, collapseWhitespace: true});

      return {
        statusCode: StatusCodes.OK,
        body: JSON.stringify(minifiedHtml),
        headers: {
          "Content-Type": "application/json"
        }
      }
    } catch (e) {
      return errorResponse(StatusCodes.BAD_REQUEST, { tag: "KeineAhnung" })
    }
    // check to see if the example is cached
  } else {
    return errorResponse(StatusCodes.BAD_REQUEST, { tag: "KeineAhnung" })
  }
}
