import {Elm} from './src/Main'

const app: Elm.Main.App = Elm.Main.init({node: document.querySelector('main'), flags: null});

app.ports.decodeRefererFromStateParam.subscribe((base64String: string) => {
    const decodedString = window.atob(base64String)
    try {
        const parsedString = JSON.parse(decodedString)
        console.log(decodedString)
    } catch (e) {
        console.log(e)
    }
})
