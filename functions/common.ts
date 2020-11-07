import {ResultResolver, Status} from "./types";

export function removeWhiteSpace(value: string): string {
  return value.replace(/\s/g, '')
}

export function Tuple<T>(): ResultResolver<T> {
  return {
    Err: { Status: Status.Err },
    Ok: (arg: T) => ({ Status: Status.Ok, data: arg })
  }
}