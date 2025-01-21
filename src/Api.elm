module Api exposing
    ( Message
    , TokenResponse
    , messageDecoder
    , request
    , tokenDecoder
    )

import Effect exposing (Effect)
import Http
import Json.Decode


apiUrl : String
apiUrl =
    "http://localhost:8080"


type alias Message =
    { message : String
    }


messageDecoder : Json.Decode.Decoder Message
messageDecoder =
    Json.Decode.map Message
        (Json.Decode.field "message" Json.Decode.string)


type alias TokenResponse =
    { token : String
    }


tokenDecoder : Json.Decode.Decoder TokenResponse
tokenDecoder =
    Json.Decode.map TokenResponse
        (Json.Decode.field "token" Json.Decode.string)


request :
    { method : String
    , token : Maybe String
    , endpoint : String
    , body : Http.Body
    , expect : Http.Expect msg
    }
    -> Effect msg
request options =
    let
        headers : List Http.Header
        headers =
            case options.token of
                Just t ->
                    [ Http.header "X-Api-Key" t
                    ]

                Nothing ->
                    []

        url : String
        url =
            apiUrl ++ options.endpoint

        cmd : Cmd msg
        cmd =
            Http.request
                { method = options.method
                , headers = headers
                , url = url
                , body = options.body
                , expect = options.expect
                , timeout = Nothing
                , tracker = Nothing
                }
    in
    Effect.sendCmd cmd
