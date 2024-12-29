module Api.Login exposing (TokenResponse, post)

import Effect exposing (Effect)
import Http
import Json.Decode
import Json.Encode


type alias TokenResponse =
    { token : String
    }


decoder : Json.Decode.Decoder TokenResponse
decoder =
    Json.Decode.map TokenResponse
        (Json.Decode.field "token" Json.Decode.string)


post :
    { onResponse : Result Http.Error TokenResponse -> msg
    , username : String
    , password : String
    }
    -> Effect msg
post options =
    let
        body : Json.Encode.Value
        body =
            Json.Encode.object
                [ ( "username", Json.Encode.string options.username )
                , ( "password", Json.Encode.string options.password )
                ]

        cmd : Cmd msg
        cmd =
            Http.post
                -- TODO: Change api to an environment variable
                { url = "http://localhost:8080/auth/login"
                , body = Http.jsonBody body
                , expect = Http.expectJson options.onResponse decoder
                }
    in
    Effect.sendCmd cmd
