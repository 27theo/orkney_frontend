import "./web-components/time-ago";
import * as ports from "./ports";

// https://github.com/elm-community/js-integration-examples/blob/master/websockets/index.html

export const flags = ({ env }) => {
    // Called before our Elm application starts
    return {
        user: JSON.parse(window.localStorage.user || null)
    };
}

export const onReady = ({ env, app }) => {
    // Called after our Elm application starts
    if (app.ports && app.ports.sendToLocalStorage) {
        app.ports.sendToLocalStorage.subscribe(ports.sendToLocalStorage);
        app.ports.skipAnimations.subscribe(ports.skipAnimations);
        app.ports.startMusic.subscribe(ports.startMusic);
        app.ports.fadeOutMusic.subscribe(ports.fadeOutMusic);
    }
}
