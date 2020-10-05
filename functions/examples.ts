import examples from "../data/examples.json"
import fs from "fs"

export async function handler() {
  return {
    statusCode: 200,
    body: JSON.stringify({examples: examples}),
    headers: {
      "Content-Type": "application/json"
    }
  }
}