module Pages.Home_ exposing (page)

import Html exposing (..)
import Html.Attributes exposing (id)
import Page exposing (Page)
import Request exposing (Request)
import Shared
import Ui
import View exposing (View)


page : Shared.Model -> Request -> Page
page model _ =
    Page.static
        { view = view model
        }


view : Shared.Model -> View msg
view _ =
    { title = title
    , body = body
    }


title : String
title =
    "Home"


body : List (Html.Html msg)
body =
    [ Ui.navbar title
    , div [ id "content" ] [ p [] [ text "This is the home page." ] ]
    ]
