module Shared exposing
    ( Flags
    , Model
    , Msg
    , decoder
    , init
    , subscriptions
    , update
    )

import Dict
import Effect exposing (Effect)
import Json.Decode
import Route exposing (Route)
import Shared.Model
import Shared.Msg



-- FLAGS


type alias Flags =
    { user : Shared.Model.User
    }


decodeUser : Json.Decode.Decoder Shared.Model.User
decodeUser =
    Json.Decode.map2 Shared.Model.User
        (Json.Decode.field "token" Json.Decode.string)
        (Json.Decode.field "username" Json.Decode.string)


decoder : Json.Decode.Decoder Flags
decoder =
    Json.Decode.map Flags
        (Json.Decode.field "user" decodeUser)



-- INIT


type alias Model =
    Shared.Model.Model


init : Result Json.Decode.Error Flags -> Route () -> ( Model, Effect Msg )
init flagsResult _ =
    let
        user : Maybe Shared.Model.User
        user =
            case flagsResult of
                Ok flags ->
                    Just
                        { token = flags.user.token
                        , username = flags.user.username
                        }

                Err _ ->
                    Nothing
    in
    ( { user = user
      , music = False
      }
    , Effect.none
    )



-- UPDATE


type alias Msg =
    Shared.Msg.Msg


update : Route () -> Msg -> Model -> ( Model, Effect Msg )
update _ msg model =
    case msg of
        Shared.Msg.SignIn user path ->
            ( { model | user = Just user }
            , Effect.batch
                [ Effect.pushRoute
                    { path = path
                    , query = Dict.empty
                    , hash = Nothing
                    }
                , Effect.saveUser user
                ]
            )

        Shared.Msg.SignOut ->
            ( { model | user = Nothing }
            , Effect.clearUser
            )

        Shared.Msg.StartMusic ->
            ( { model | music = True }
            , Effect.sendCmd (Effect.startMusic ())
            )

        Shared.Msg.FadeOutMusic ->
            ( { model | music = False }
            , Effect.sendCmd (Effect.fadeOutMusic ())
            )



-- SUBSCRIPTIONS


subscriptions : Route () -> Model -> Sub Msg
subscriptions _ _ =
    Sub.none
