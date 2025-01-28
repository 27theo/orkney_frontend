module Api.Games exposing
    ( Game
    , GamesList
    , PlayerState
    , State
    , activate
    , create
    , delete
    , gamesListDecoder
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
    , state : State
    }


type alias GamesList =
    { games : List Game
    }


type alias PlayerState =
    { uuid : String
    , username : String
    , gold : Int
    }


type alias State =
    { player_states : List PlayerState }


gameDecoder : Json.Decode.Decoder Game
gameDecoder =
    Json.Decode.map7 Game
        (Json.Decode.field "guid" Json.Decode.string)
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "is_active" Json.Decode.bool)
        (Json.Decode.field "created_at" Json.Decode.string)
        (Json.Decode.field "players" (Json.Decode.list Json.Decode.string))
        (Json.Decode.field "owner" Json.Decode.string)
        (Json.Decode.field "state" stateDecoder)


gamesListDecoder : Json.Decode.Decoder GamesList
gamesListDecoder =
    Json.Decode.map GamesList
        (Json.Decode.field "games" (Json.Decode.list gameDecoder))


playerStateDecoder : Json.Decode.Decoder PlayerState
playerStateDecoder =
    Json.Decode.map3 PlayerState
        (Json.Decode.field "uuid" Json.Decode.string)
        (Json.Decode.field "username" Json.Decode.string)
        (Json.Decode.field "gold" Json.Decode.int)


stateDecoder : Json.Decode.Decoder State
stateDecoder =
    Json.Decode.map State
        (Json.Decode.field "player_states" (Json.Decode.list playerStateDecoder))


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


activate :
    { onResponse : Result Http.Error Message -> msg
    , token : String
    , guid : String
    }
    -> Effect msg
activate options =
    Api.request
        { method = "POST"
        , token = Just options.token
        , endpoint = "/games/activate/" ++ options.guid
        , body = Http.emptyBody
        , expect = Http.expectJson options.onResponse messageDecoder
        }
