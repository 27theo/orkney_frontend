import { ElmLand } from "./interop";

export function sendToLocalStorage(data: unknown) {
    const { key, value } = data as Record<string, string>;
    window.localStorage[key] = JSON.stringify(value);
}

export function skipAnimations() {
    document.getAnimations().forEach((a) => {
        if (a.playState == "running") {
            a.playbackRate = 10;
        }
    });
}

export function startMusic() {
    var audio = <HTMLAudioElement>document.getElementById("audio");
    if (audio == null) {
        audio = document.createElement("audio");
    }
    audio.volume = 1;
    audio.currentTime = 0;
    audio.setAttribute("id", "audio");
    audio.setAttribute("autoplay", "autoplay");

    const source = document.createElement("source");
    source.setAttribute("src", "/assets/music/wrigley_faded.mp3");

    audio.appendChild(source);
    document.getElementsByTagName("body")[0].appendChild(audio);
    audio.play();
}

export function fadeOutMusic() {
    const audio = <HTMLAudioElement>document.getElementById("audio");
    if (audio == null) return;
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
            audio.volume = 1;
            clearInterval(fadeAudio);
        }
    }, 100);
}

export function watchGames(app: ElmLand.App) {
    if (globalThis.watchGames == undefined) {
        globalThis.watchGames = new WebSocket("ws://localhost:8080/ws/games");
        globalThis.watchGames.addEventListener("message", (event) => {
            app.ports?.watchGamesReceiver?.send?.(event.data);
        });
        globalThis.watchGames.onclose =
            () => { globalThis.watchGames = undefined; };
    }
}
