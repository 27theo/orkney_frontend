module Api.Games exposing
    ( Game
    , GamesList
    , getAll
    , getSingle
    , join
    , leave
    )

import Api exposing (Message, messageDecoder)
import Effect exposing (Effect)
import Http
import Json.Decode


type alias Game =
    { guid : String
    , name : String
    , is_active : Bool
    , created_at : String
    , players : List String
    , owner : String
    }


type alias GamesList =
    { games : List Game
    }


gameDecoder : Json.Decode.Decoder Game
gameDecoder =
    Json.Decode.map6 Game
        (Json.Decode.field "guid" Json.Decode.string)
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "is_active" Json.Decode.bool)
        (Json.Decode.field "created_at" Json.Decode.string)
        (Json.Decode.field "players" (Json.Decode.list Json.Decode.string))
        (Json.Decode.field "owner" Json.Decode.string)


gamesListDecoder : Json.Decode.Decoder GamesList
gamesListDecoder =
    Json.Decode.map GamesList
        (Json.Decode.field "games" (Json.Decode.list gameDecoder))


getAll :
    { onResponse : Result Http.Error GamesList -> msg
    , token : String
    }
    -> Effect msg
getAll options =
    let
        headers : List Http.Header
        headers =
            [ Http.header "X-Api-Key" options.token
            ]

        cmd : Cmd msg
        cmd =
            Http.request
                -- TODO: Change api to an environment variable
                { method = "GET"
                , headers = headers
                , url = "http://localhost:8080/games/"
                , body = Http.emptyBody
                , expect = Http.expectJson options.onResponse gamesListDecoder
                , timeout = Nothing
                , tracker = Nothing
                }
    in
    Effect.sendCmd cmd


getSingle :
    { onResponse : Result Http.Error Game -> msg
    , token : String
    , guid : String
    }
    -> Effect msg
getSingle options =
    let
        headers : List Http.Header
        headers =
            [ Http.header "X-Api-Key" options.token
            ]

        url : String
        url =
            String.concat [ "http://localhost:8080/games/", options.guid ]

        cmd : Cmd msg
        cmd =
            Http.request
                -- TODO: Change api to an environment variable
                { method = "GET"
                , headers = headers
                , url = url
                , body = Http.emptyBody
                , expect = Http.expectJson options.onResponse gameDecoder
                , timeout = Nothing
                , tracker = Nothing
                }
    in
    Effect.sendCmd cmd


join :
    { onResponse : Result Http.Error Message -> msg
    , token : String
    , guid : String
    }
    -> Effect msg
join options =
    let
        headers : List Http.Header
        headers =
            [ Http.header "X-Api-Key" options.token
            ]

        url : String
        url =
            String.concat [ "http://localhost:8080/games/join/", options.guid ]

        cmd : Cmd msg
        cmd =
            Http.request
                -- TODO: Change api to an environment variable
                { method = "POST"
                , headers = headers
                , url = url
                , body = Http.emptyBody
                , expect = Http.expectJson options.onResponse messageDecoder
                , timeout = Nothing
                , tracker = Nothing
                }
    in
    Effect.sendCmd cmd


leave :
    { onResponse : Result Http.Error Message -> msg
    , token : String
    , guid : String
    }
    -> Effect msg
leave options =
    let
        headers : List Http.Header
        headers =
            [ Http.header "X-Api-Key" options.token
            ]

        url : String
        url =
            String.concat [ "http://localhost:8080/games/leave/", options.guid ]

        cmd : Cmd msg
        cmd =
            Http.request
                -- TODO: Change api to an environment variable
                { method = "POST"
                , headers = headers
                , url = url
                , body = Http.emptyBody
                , expect = Http.expectJson options.onResponse messageDecoder
                , timeout = Nothing
                , tracker = Nothing
                }
    in
    Effect.sendCmd cmd
