module Pages.Home_ exposing (Model, Msg, page)

import Effect exposing (Effect)
import Html exposing (Html)
import Html.Attributes as Attr
import Page exposing (Page)
import Route exposing (Route)
import Shared
import View exposing (View)


page : Shared.Model -> Route () -> Page Model Msg
page _ _ =
    Page.new
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- INIT


type alias Model =
    {}


init : () -> ( Model, Effect msg )
init () =
    ( {}, Effect.none )



-- UPDATE


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Effect.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> View msg
view model =
    { title = "Welcome to Lords of Orkney"
    , body = [ viewPage model ]
    }


viewPage : Model -> Html msg
viewPage _ =
    Html.div [ Attr.id "jumbo" ]
        [ Html.div [ Attr.id "content" ]
            [ Html.p [ Attr.id "title" ] [ Html.text "Lords of Orkney" ]
            , Html.p [ Attr.id "author" ] [ Html.text "Ferdinand Addis" ]
            ]
        ]
