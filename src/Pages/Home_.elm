module Pages.Home_ exposing (Model, Msg, page)

import Browser.Events
import Effect exposing (Effect)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Json.Decode exposing (succeed)
import Page exposing (Page)
import Route exposing (Route)
import Route.Path
import Shared
import View exposing (View)


page : Shared.Model -> Route () -> Page Model Msg
page shared _ =
    Page.new
        { init = init
        , update = update shared
        , subscriptions = subscriptions
        , view = view shared
        }



-- INIT


type alias Model =
    {}


init : () -> ( Model, Effect msg )
init () =
    ( {}, Effect.none )



-- UPDATE


type Msg
    = KeyDown
    | Clicked
    | PushRoute Route.Path.Path


update : Shared.Model -> Msg -> Model -> ( Model, Effect Msg )
update shared msg model =
    case msg of
        KeyDown ->
            ( model
            , Effect.sendCmd (Effect.skipAnimations ())
            )

        Clicked ->
            ( model
            , if shared.music then
                Effect.none

              else
                Effect.sendForTheMusicians
            )

        PushRoute route ->
            ( model
            , Effect.batch
                [ Effect.pushRoutePath route
                , Effect.sendCmd (Effect.fadeOutMusic ())
                ]
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Browser.Events.onKeyDown (succeed KeyDown)
        , Browser.Events.onClick (succeed Clicked)
        ]



-- VIEW


view : Shared.Model -> Model -> View Msg
view shared _ =
    { title = "Welcome to Lords of Orkney"
    , body = [ viewPage shared ]
    }


viewPage : Shared.Model -> Html Msg
viewPage shared =
    if shared.music then
        viewJumbo ()

    else
        Html.div [ Attr.id "enter" ]
            [ Html.div []
                [ Html.p [ Attr.id "click" ] [ Html.text "Click anywhere to enter..." ]
                , Html.a
                    [ Attr.id "skip"
                    , Events.onClick (PushRoute Route.Path.Games)
                    ]
                    [ Html.text "Or click here to skip to the site!" ]
                ]
            ]


viewJumbo : () -> Html Msg
viewJumbo () =
    Html.div [ Attr.id "jumbo" ]
        [ Html.div [ Attr.id "content" ]
            [ Html.p [ Attr.id "title" ] [ Html.text "Lords of Orkney" ]
            , Html.div [ Attr.id "under" ]
                [ Html.p [ Attr.id "author" ] [ Html.text "Ferdinand Addis" ]
                , Html.a [ Events.onClick (PushRoute Route.Path.Games) ]
                    [ Html.img
                        [ Attr.id "sword", Attr.src "/assets/img/sword.png" ]
                        []
                    ]
                ]
            ]
        , Html.div [ Attr.id "bottom" ]
            [ Html.p [ Attr.id "skip" ]
                [ Html.text "(Press space to skip)"
                ]
            ]
        ]
