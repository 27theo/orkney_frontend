module Api.Login exposing (post)

import Api exposing (TokenResponse, tokenDecoder)
import Effect exposing (Effect)
import Http
import Json.Encode


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
    in
    Api.request
        { method = "POST"
        , token = Nothing
        , endpoint = "/auth/login"
        , body = Http.jsonBody body
        , expect = Http.expectJson options.onResponse tokenDecoder
        }
