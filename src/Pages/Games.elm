module Pages.Games exposing (Model, Msg, page)

import Api.Games
import Auth
import Effect exposing (Effect)
import Html exposing (Html)
import Html.Attributes as Attr
import Http
import Layouts
import Page exposing (Page)
import Route exposing (Route)
import Shared
import View exposing (View)


page : Auth.User -> Shared.Model -> Route () -> Page Model Msg
page user _ _ =
    Page.new
        { init = init user
        , update = update user
        , subscriptions = subscriptions
        , view = view
        }
        |> Page.withLayout (toLayout user)


toLayout : Auth.User -> Model -> Layouts.Layout Msg
toLayout user _ =
    Layouts.Navbar
        { user = Just user
        }



-- INIT


type alias Model =
    { requestingGames : Bool
    , user : Auth.User
    }


init : Auth.User -> () -> ( Model, Effect Msg )
init user () =
    ( { requestingGames = True
      , user = user
      }
    , Effect.sendMsg ApiRequestGames
    )



-- UPDATE


type Msg
    = ApiRequestGames
    | ApiRespondedGames (Result Http.Error Api.Games.GamesList)


update : Auth.User -> Msg -> Model -> ( Model, Effect Msg )
update user msg model =
    case msg of
        ApiRequestGames ->
            ( model
            , Api.Games.post
                { onResponse = ApiRespondedGames
                , token = user.token
                }
            )

        ApiRespondedGames result ->
            let
                _ =
                    Debug.log "result" result
            in
            ( { model | requestingGames = False }
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Pages.Games"
    , body = [ viewPage model ]
    }


viewPage : Model -> Html Msg
viewPage model =
    Html.div [ Attr.id "content" ]
        [ Html.p [] [ Html.text "/games" ]
        , Html.p []
            [ Html.text <|
                if model.requestingGames then
                    "Requesting..."

                else
                    "Got games list!"
            ]
        ]
