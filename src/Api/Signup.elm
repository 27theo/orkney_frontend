module Api.Signup exposing (post)

import Api exposing (TokenResponse, tokenDecoder)
import Effect exposing (Effect)
import Http
import Json.Encode


post :
    { onResponse : Result Http.Error TokenResponse -> msg
    , username : String
    , password : String
    , email : String
    }
    -> Effect msg
post options =
    let
        body : Json.Encode.Value
        body =
            Json.Encode.object
                [ ( "username", Json.Encode.string options.username )
                , ( "password", Json.Encode.string options.password )
                , ( "email", Json.Encode.string options.email )
                ]

        cmd : Cmd msg
        cmd =
            Http.post
                -- TODO: Change api to an environment variable
                { url = "http://localhost:8080/auth/signup"
                , body = Http.jsonBody body
                , expect = Http.expectJson options.onResponse tokenDecoder
                }
    in
    Effect.sendCmd cmd
