import { Elm } from './src/Main.elm'

var app = Elm.Main.init({node: document.querySelector('main'), flags: {}});

app.ports.decodeRefererFromStateParam.subscribe((base64String) => {
    const decodedString = window.atob(base64String)
    try {
        const parsedString = JSON.parse(decodedString)
        console.log(decodedString)
    } catch (e) {
       throw e
    }
})
// app.ports.storeCache.subscribe(function(val) {
//
//   if (val === null) {
//     localStorage.removeItem(storageKey);
//   } else {
//     localStorage.setItem(storageKey, JSON.stringify(val));
//   }
//
//   // Report that the new session was stored successfully.
//   setTimeout(function() { app.ports.onStoreChange.send(val); }, 0);
// });
//
// // Whenever localStorage changes in another tab, report it if necessary.
// window.addEventListener("storage", function(event) {
//   if (event.storageArea === localStorage && event.key === storageKey) {
//     app.ports.onStoreChange.send(event.newValue);
//   }
// }, false);
