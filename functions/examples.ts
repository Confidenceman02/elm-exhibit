import examples from "../data/examples.json"

export async function handler() {
  return {
    statusCode: 200,
    body: JSON.stringify(examples),
  }
}