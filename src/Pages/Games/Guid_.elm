module Pages.Games.Guid_ exposing (Model, Msg, page)

import Api.Games exposing (Game)
import Auth
import Effect exposing (Effect)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Http
import Layouts
import Page exposing (Page)
import Route exposing (Route)
import Route.Path
import Shared
import Url exposing (Protocol(..))
import View exposing (View)


page : Auth.User -> Shared.Model -> Route { guid : String } -> Page Model Msg
page user _ route =
    Page.new
        { init = init user route.params.guid
        , update = update
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
    { guid : String
    , game : Maybe (Result String Game)
    }


init : Auth.User -> String -> () -> ( Model, Effect Msg )
init user guid () =
    ( { guid = guid
      , game = Nothing
      }
    , Api.Games.getSingle
        { onResponse = ApiRespondedGame
        , token = user.token
        , guid = guid
        }
    )



-- UPDATE


type Msg
    = ApiRespondedGame (Result Http.Error Game)
    | PushRoute Route.Path.Path


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        ApiRespondedGame (Ok game) ->
            ( { model | game = Just (Ok game) }
            , Effect.none
            )

        ApiRespondedGame (Err _) ->
            ( { model
                | game = Just (Err """I could not fetch that game from the API
                - are you sure that this page links to a valid game? Please try
                again if so.""")
              }
            , Effect.none
            )

        PushRoute route ->
            ( model
            , Effect.pushRoutePath route
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    let
        title =
            case model.game of
                Nothing ->
                    "Loading game..."

                Just (Err _) ->
                    "No game found"

                Just (Ok game) ->
                    game.name
    in
    { title = title
    , body = [ viewPage model title ]
    }


viewPage : Model -> String -> Html Msg
viewPage model title =
    Html.div [ Attr.id "content" ]
        [ Html.button
            [ Events.onClick (PushRoute Route.Path.Games)
            , Attr.id "return"
            ]
            [ Html.text "Return" ]
        , Html.p [ Attr.id "gametitle" ] [ Html.text title ]
        , case model.game of
            Nothing ->
                Html.p [] [ Html.text "Requesting game information..." ]

            Just (Err message) ->
                Html.p [] [ Html.text message ]

            Just (Ok game) ->
                viewGame game
        ]


viewGame : Game -> Html Msg
viewGame game =
    Html.div [ Attr.id "game" ]
        [ Html.div [ Attr.id "playerslist" ]
            [ Html.span [ Attr.id "players" ] []
            , Html.ul []
                (List.map (\p -> Html.li [] [ Html.text p ]) game.players)
            ]
        , Html.div []
            [ Html.span
                [ Attr.id "created_at" ]
                [ timeAgo game.created_at ]
            ]
        ]


timeAgo : String -> Html Msg
timeAgo epoch =
    case String.toInt epoch of
        Just e ->
            Html.node "time-ago"
                [ Attr.attribute "epoch" (String.fromInt (e * 1000)) ]
                []

        Nothing ->
            Html.span [] [ Html.text "(could not convert time)" ]
