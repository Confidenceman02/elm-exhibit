// eslint-disable-next-line @typescript-eslint/ban-ts-comment
//@ts-ignore
import { Elm } from "./src/Main";

const app = Elm.Main.init({
  node: document.querySelector("main"),
  flags: null,
});

app.ports.decodeRefererFromStateParam.subscribe((base64String: string) => {
  const decodedString = window.atob(base64String);
  try {
    const parsedJSON = JSON.parse(decodedString);
    app.ports.decodedRefererFromStateParam.send(parsedJSON.referer);
  } catch (e) {
    console.log(e);
  }
});
