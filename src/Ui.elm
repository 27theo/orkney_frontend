module Ui exposing (navbar)

import Gen.Route as Route exposing (Route)
import Html exposing (..)
import Html.Attributes exposing (..)


navbar : String -> Html msg
navbar active =
    div [ id "navbar" ]
        [ viewLink active "Home" Route.Home_
        , viewLink active "Rooms" Route.Rooms
        , viewLink active "Login" Route.Login
        ]


viewLink : String -> String -> Route -> Html msg
viewLink active label route =
    let
        idActive =
            if active == label then
                id "active"

            else
                id ""
    in
    Html.a [ idActive, href (Route.toHref route) ] [ Html.text label ]
