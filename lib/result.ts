export enum Status {
  Err,
  Ok,
}

export type ResultType<T> =
  | { Status: Status.Ok; data: T }
  | { Status: Status.Err };

interface ResultResolver<T> {
  Err: { Status: Status.Err };
  Ok: (arg: T) => { Status: Status.Ok; data: T };
}

export function Result<T>(): ResultResolver<T> {
  return {
    Err: { Status: Status.Err },
    Ok: (arg: T) => ({ Status: Status.Ok, data: arg }),
  };
}
