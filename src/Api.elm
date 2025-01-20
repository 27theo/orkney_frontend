module Api exposing (Message, messageDecoder)

import Json.Decode


type alias Message =
    { message : String
    }


messageDecoder : Json.Decode.Decoder Message
messageDecoder =
    Json.Decode.map Message
        (Json.Decode.field "message" Json.Decode.string)
