module Pages.Login exposing (Model, Msg, page)

import Api
import Effect exposing (Effect)
import Errors exposing (ltk)
import Gen.Params.Login exposing (Params)
import Html exposing (..)
import Html.Attributes exposing (id, name, placeholder, type_)
import Html.Events as Events
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Page
import Request
import Shared
import Ui
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page _ _ =
    Page.advanced
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- INIT


type alias Model =
    { username : String
    , password : String
    , message : Maybe String
    }


init : ( Model, Effect Msg )
init =
    ( { username = "", password = "", message = Nothing }
    , Effect.none
    )



-- UPDATE


type Msg
    = ClickedLogIn
    | UsernameInput String
    | PasswordInput String
    | GotLoginResponse (Result String ( String, String ))


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        ClickedLogIn ->
            logIn model

        UsernameInput s ->
            ( { model | username = s }
            , Effect.none
            )

        PasswordInput s ->
            ( { model | password = s }
            , Effect.none
            )

        GotLoginResponse r ->
            case r of
                Err message ->
                    ( { model | message = Just message }, Effect.none )

                Ok ( username, token ) ->
                    let
                        user =
                            { username = username
                            , token = token
                            }
                    in
                    ( model, Effect.fromShared (Shared.LogIn user) )


logIn : Model -> ( Model, Effect Msg )
logIn model =
    ( model
    , Http.post
        { url = String.concat [ Api.url, "/auth/login" ]
        , body = Http.jsonBody (loginBodyEncoder model.username model.password)
        , expect = Http.expectStringResponse GotLoginResponse parseLoginResponse
        }
        |> Effect.fromCmd
    )


loginBodyEncoder : String -> String -> Encode.Value
loginBodyEncoder username password =
    Encode.object
        [ ( "username", Encode.string username )
        , ( "password", Encode.string password )
        ]


parseLoginResponse : Http.Response String -> Result String ( String, String )
parseLoginResponse response =
    case response of
        Http.BadUrl_ _ ->
            Err (ltk "Err, this should never happen - the login request was attempted with a bad URL")

        Http.Timeout_ ->
            Err (ltk "Oh dear - it appears that the entire game server might be down")

        Http.NetworkError_ ->
            Err (ltk "I've encountered a network error. You might not be connected to the internet? If you are, something has gone wrong")

        Http.BadStatus_ metadata _ ->
            Err <|
                if metadata.statusCode == 401 then
                    "Login failed, please check that your username and password are correct."

                else
                    String.concat
                        [ "Hm. The login request to the server failed with error code "
                        , String.fromInt metadata.statusCode
                        ]
                        |> ltk

        Http.GoodStatus_ _ body ->
            case Decode.decodeString (Decode.field "token" Decode.string) body of
                Err _ ->
                    Err (ltk "The server is acting as if everything is okay, but hasn't responded with a login token")

                Ok token ->
                    Ok ( "", token )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = title
    , body = viewBody model
    }


title : String
title =
    "Login"


viewBody : Model -> List (Html Msg)
viewBody model =
    [ Ui.navbar title
    , viewLogInForm
    , viewMessage model
    ]


viewMessage : Model -> Html Msg
viewMessage model =
    p [] [ text (Maybe.withDefault "" model.message) ]


viewLogInForm : Html Msg
viewLogInForm =
    Html.form [ Events.onSubmit ClickedLogIn, id "logInForm" ]
        [ input [ Events.onInput UsernameInput, name "username", placeholder "Username" ] []
        , br [] []
        , input [ Events.onInput PasswordInput, type_ "password", name "password", placeholder "Password" ] []
        , br [] []
        , button [] [ text "Log in" ]
        ]
