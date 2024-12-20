module Pages.Login exposing (Model, Msg, page)

import Api
import Dict exposing (get)
import Effect exposing (Effect)
import Errors exposing (ltk)
import Gen.Params.Login exposing (Params)
import Html exposing (..)
import Html.Attributes exposing (id, name, placeholder, type_)
import Html.Events as Events
import Http
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
    { username : Maybe String
    , password : Maybe String
    , message : Maybe String
    }


init : ( Model, Effect Msg )
init =
    ( { username = Nothing, password = Nothing, message = Nothing }
    , Effect.none
    )



-- UPDATE


type Msg
    = ClickedLogIn
    | UsernameInput String
    | PasswordInput String
    | GotLoginResponse (Result String String)


loginBodyEncoder : String -> String -> Encode.Value
loginBodyEncoder username password =
    Encode.object
        [ ( "username", Encode.string username )
        , ( "password", Encode.string password )
        ]


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        ClickedLogIn ->
            logIn model

        UsernameInput s ->
            ( { model | username = Just s }
            , Effect.none
            )

        PasswordInput s ->
            ( { model | password = Just s }
            , Effect.none
            )

        GotLoginResponse r ->
            case r of
                Err s ->
                    ( { model | message = Just s }, Effect.none )

                Ok s ->
                    ( { model | message = Just s }, Effect.none )


logIn : Model -> ( Model, Effect Msg )
logIn model =
    let
        username =
            Maybe.withDefault "" model.username
    in
    let
        password =
            Maybe.withDefault "" model.password
    in
    ( model
    , Http.post
        { url = String.concat [ Api.url, "/auth/login" ]
        , body = Http.jsonBody (loginBodyEncoder username password)
        , expect = Http.expectStringResponse GotLoginResponse parseLoginResponse
        }
        |> Effect.fromCmd
    )


parseLoginResponse : Http.Response String -> Result String String
parseLoginResponse response =
    case response of
        Http.BadUrl_ _ ->
            Err (ltk "Err, this should never happen - the login request was attempted with a bad URL")

        Http.Timeout_ ->
            Err (ltk "Oh dear - it appears that the entire game server is down")

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

        Http.GoodStatus_ metadata _ ->
            extractToken metadata


extractToken : Http.Metadata -> Result String String
extractToken metadata =
    let _ = Debug.log "headers" metadata.headers in
    case
        get "uuid" metadata.headers
    of
        Nothing ->
            Err (ltk "The server didn't repond with the correct data header")

        Just uuid ->
            Ok uuid



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
