import "./web-components/time-ago";

export const flags = ({ env }) => {
    // Called before our Elm application starts
    return {
        user: JSON.parse(window.localStorage.user || null)
    };
}

export const onReady = ({ env, app }) => {
    // Called after our Elm application starts
    if (app.ports && app.ports.sendToLocalStorage) {
        app.ports.sendToLocalStorage.subscribe(({ key, value }) => {
            window.localStorage[key] = JSON.stringify(value);
        });

        app.ports.skipAnimations.subscribe(() => {
            document.getAnimations().forEach((a) => {
                if (a.playState == "running") {
                    a.playbackRate = 10;
                }
            })
        });

        app.ports.startMusic.subscribe(() => {
            const music = document.createElement("audio");
            music.setAttribute("autoplay", "autoplay");
            const source = document.createElement("source");
            source.setAttribute("src", "/assets/music/wrigley_faded.mp3");
            music.appendChild(source);
            document.getElementsByTagName("body")[0].appendChild(music);
        });
    }
}
