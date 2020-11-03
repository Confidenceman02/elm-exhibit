export namespace Elm {
  namespace Main {
    export interface App {
      ports: {
        decodeRefererFromStateParam: {
          subscribe(callback: (data: string) => void): void
        }
        decodedRefererFromStateParam: {
          send(data: string)
        }
      };
    }
    export function init(options: {
      node?: HTMLElement | null;
      flags: null;
    }): Elm.Main.App;
  }
}