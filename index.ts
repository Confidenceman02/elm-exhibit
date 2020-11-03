import {Elm} from './src/Main'

const app: Elm.Main.App = Elm.Main.init({node: document.querySelector('main'), flags: null});

app.ports.decodeRefererFromStateParam.subscribe((base64String: string) => {
    const decodedString = window.atob(base64String)
    try {
        const parsedJSON: { sessionId: string; referer: string;} = JSON.parse(decodedString)
        app.ports.decodedRefererFromStateParam.send(parsedJSON.referer)
    } catch (e) {
        console.log(e)
    }
})
