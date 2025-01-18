export function sendToLocalStorage({ key, value }) {
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
    var audio = document.getElementById("audio");
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
            audio.volume = 1;
            clearInterval(fadeAudio);
        }
    }, 100);
}
