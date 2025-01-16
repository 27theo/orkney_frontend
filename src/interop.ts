import './web-components/time-ago.ts'

export const flags = ({ env }: any) => {
    // Called before our Elm application starts
    return {
        user: JSON.parse(window.localStorage.user || null)
    }
}

export const onReady = ({ env, app }: any) => {
    // Called after our Elm application starts
    if (app.ports && app.ports.sendToLocalStorage) {
        app.ports.sendToLocalStorage.subscribe(({ key, value }: any) => {
            window.localStorage[key] = JSON.stringify(value)
        })
    }
}
