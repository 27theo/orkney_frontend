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
            const audio = document.createElement("audio");
            audio.setAttribute("id", "audio");
            audio.setAttribute("autoplay", "autoplay");
            const source = document.createElement("source");
            source.setAttribute("src", "/assets/music/wrigley_faded.mp3");
            audio.appendChild(source);
            document.getElementsByTagName("body")[0].appendChild(audio);
        });

        app.ports.fadeOutMusic.subscribe(() => {
            const audio = document.getElementById("audio");
            var time = 0;
            const fadeAudio = setInterval(() => {
                time += 0.1;
                if (audio.volume !== 0) {
                    const dec = Math.sin((time * Math.PI) / 2);
                    audio.volume -= 0.1;
                }
                if (audio.volume < 0.003) {
                    audio.pause();
                    audio.currentTime = 0;
                    clearInterval(fadeAudio);
                }
            }, 100);
        });
    }
}
