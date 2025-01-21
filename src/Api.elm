module Api exposing (Message, TokenResponse, messageDecoder, tokenDecoder)

import Json.Decode


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
