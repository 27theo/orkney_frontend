module Layouts.Navbar exposing (Model, Msg, Props, layout)

import Auth
import Effect exposing (Effect)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events
import Layout exposing (Layout)
import Route exposing (Route)
import Shared
import View exposing (View)


type alias Props =
    { user : Maybe Auth.User
    }


layout : Props -> Shared.Model -> Route () -> Layout () Model Msg contentMsg
layout props _ route =
    Layout.new
        { init = init
        , update = update
        , view = view props route
        , subscriptions = subscriptions
        }



-- INIT


type alias Model =
    {}


init : () -> ( Model, Effect Msg )
init _ =
    ( {}
    , Effect.none
    )



-- UPDATE


type Msg
    = UserClickedLogout


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        UserClickedLogout ->
            ( model
            , Effect.signOut
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view :
    Props
    -> Route ()
    ->
        { toContentMsg : Msg -> contentMsg
        , model : Model
        , content : View contentMsg
        }
    -> View contentMsg
view props _ params =
    { title = params.content.title ++ " | Lords of Orkney"
    , body =
        [ viewNavbar props
            |> Html.map params.toContentMsg
        , viewMainContent params.content
        ]
    }


viewNavbar : Props -> Html Msg
viewNavbar props =
    Html.div [ Attr.id "navbar" ]
        [ Html.a [ Attr.id "title", Attr.href "/" ] [ Html.text "Lords of Orkney" ]
        , Html.span [ Attr.id "divider" ] [ Html.text "·" ]
        , viewLeftLinks
        , viewRightLinks props
        ]


viewLeftLinks : Html Msg
viewLeftLinks =
    Html.div [ Attr.id "links" ]
        [ Html.a [ Attr.href "/games" ] [ Html.text "Games" ]
        ]


viewRightLinks : Props -> Html Msg
viewRightLinks props =
    Html.div [ Attr.id "links" ]
        [ case props.user of
            Just _ ->
                Html.a
                    [ Html.Events.onClick UserClickedLogout ]
                    [ Html.text "Logout" ]

            Nothing ->
                Html.a [ Attr.href "/login" ]
                    [ Html.text "Login"
                    ]
        ]


viewMainContent : View contentMsg -> Html contentMsg
viewMainContent content =
    Html.div [ Attr.id "page" ] content.body
