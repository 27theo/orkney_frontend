module Pages.Rooms exposing (Model, Msg, page)

import Effect exposing (Effect)
import Gen.Params.Rooms exposing (Params)
import Html exposing (..)
import Page
import Request
import Shared exposing (User)
import Ui
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page shared req =
    Page.protected.advanced
        (\user ->
            { init = init user
            , update = update
            , view = view
            , subscriptions = subscriptions
            }
        )



-- INIT


type alias Model =
    { user : User }


init : User -> ( Model, Effect Msg )
init user =
    ( { user = user }, Effect.none )



-- UPDATE


type Msg
    = ReplaceMe


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        ReplaceMe ->
            ( model, Effect.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = title
    , body = body model
    }


title : String
title =
    "Rooms"


body : Model -> List (Html.Html msg)
body model =
    [ Ui.navbar title
    , p [] [ text (String.concat [ "Logged in as ", model.user.username ]) ]
    , p [] [ text "Display list of rooms here..." ]
    ]
