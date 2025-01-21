module Api.Games exposing
    ( Game
    , GamesList
    , create
    , delete
    , getAll
    , getSingle
    , join
    , leave
    )

import Api exposing (Message, messageDecoder)
import Effect exposing (Effect)
import Http
import Json.Decode
import Json.Encode


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
    Api.request
        { method = "GET"
        , token = Just options.token
        , endpoint = "/games/"
        , body = Http.emptyBody
        , expect = Http.expectJson options.onResponse gamesListDecoder
        }


getSingle :
    { onResponse : Result Http.Error Game -> msg
    , token : String
    , guid : String
    }
    -> Effect msg
getSingle options =
    Api.request
        { method = "GET"
        , token = Just options.token
        , endpoint = "/games/" ++ options.guid
        , body = Http.emptyBody
        , expect = Http.expectJson options.onResponse gameDecoder
        }


join :
    { onResponse : Result Http.Error Message -> msg
    , token : String
    , guid : String
    }
    -> Effect msg
join options =
    Api.request
        { method = "POST"
        , token = Just options.token
        , endpoint = "/games/join/" ++ options.guid
        , body = Http.emptyBody
        , expect = Http.expectJson options.onResponse messageDecoder
        }


leave :
    { onResponse : Result Http.Error Message -> msg
    , token : String
    , guid : String
    }
    -> Effect msg
leave options =
    Api.request
        { method = "POST"
        , token = Just options.token
        , endpoint = "/games/leave/" ++ options.guid
        , body = Http.emptyBody
        , expect = Http.expectJson options.onResponse messageDecoder
        }


create :
    { onResponse : Result Http.Error Message -> msg
    , token : String
    , name : String
    }
    -> Effect msg
create options =
    let
        body : Json.Encode.Value
        body =
            Json.Encode.object
                [ ( "name", Json.Encode.string options.name )
                ]
    in
    Api.request
        { method = "POST"
        , token = Just options.token
        , endpoint = "/games/create"
        , body = Http.jsonBody body
        , expect = Http.expectJson options.onResponse messageDecoder
        }


delete :
    { onResponse : Result Http.Error Message -> msg
    , token : String
    , guid : String
    }
    -> Effect msg
delete options =
    Api.request
        { method = "POST"
        , token = Just options.token
        , endpoint = "/games/delete/" ++ options.guid
        , body = Http.emptyBody
        , expect = Http.expectJson options.onResponse messageDecoder
        }
