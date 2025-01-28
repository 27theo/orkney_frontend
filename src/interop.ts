import * as Ports from "./ports";

// Types for Elm Land interop functions
export namespace ElmLand {
    export type Port = {
        subscribe?: (callback: (data: unknown) => void) => void,
        unsubscribe?: (callback: (data: unknown) => void) => void,
        send?: (data: unknown) => void
    }

    export type Env = Record<string, string>
    export type App = { ports?: Record<string, Port> }

    export type FlagsFunction =
        ({ env }: { env: Record<string, string> }) => unknown

    export type OnReadyFunction = ({ env, app }: {
        env: Env,
        app: App
    }) => void
}

declare global {
    var watchGames: WebSocket | undefined;
}

export const flags: ElmLand.FlagsFunction = () => {
    // Called before our Elm application starts
    return {
        user: JSON.parse(window.localStorage.user || null)
    };
}

export const onReady: ElmLand.OnReadyFunction = ({ app, env }) => {
    // Called after our Elm application starts
    app.ports?.skipAnimations?.subscribe?.(Ports.skipAnimations);
    app.ports?.startMusic?.subscribe?.(Ports.startMusic);
    app.ports?.fadeOutMusic?.subscribe?.(Ports.fadeOutMusic);
    app.ports?.sendToLocalStorage?.subscribe?.(Ports.sendToLocalStorage);
    app.ports?.watchGames?.subscribe?.(() => Ports.watchGames(app));
}
