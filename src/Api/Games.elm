module Api.Games exposing (GamesList, post)

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


post :
    { onResponse : Result Http.Error GamesList -> msg
    , token : String
    }
    -> Effect msg
post options =
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
