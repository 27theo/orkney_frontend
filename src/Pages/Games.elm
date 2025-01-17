module Pages.Games exposing (Model, Msg, page)

import Api.Games exposing (Game, GamesList)
import Auth
import Dict
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
import View exposing (View)


page : Auth.User -> Shared.Model -> Route () -> Page Model Msg
page user _ _ =
    Page.new
        { init = init user
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
    { games : Maybe (Result String GamesList)
    , user : Auth.User
    }


init : Auth.User -> () -> ( Model, Effect Msg )
init user () =
    ( { user = user
      , games = Nothing
      }
    , Api.Games.getAll
        { onResponse = ApiRespondedGames
        , token = user.token
        }
    )



-- UPDATE


type Msg
    = ApiRespondedGames (Result Http.Error GamesList)
    | JoinGame String
    | ViewGame String


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        ApiRespondedGames (Ok games) ->
            ( { model | games = Just (Ok games) }
            , Effect.none
            )

        ApiRespondedGames (Err _) ->
            ( { model
                | games =
                    Just
                        (Err "Failed to fetch games list from API. Please try again.")
              }
            , Effect.none
            )

        JoinGame guid ->
            ( model
            , Effect.pushRoute
                { path = Route.Path.Games_Guid_ { guid = guid }
                , query = Dict.empty
                , hash = Nothing
                }
            )

        ViewGame guid ->
            ( model
            , Effect.pushRoute
                { path = Route.Path.Games_Guid_ { guid = guid }
                , query = Dict.empty
                , hash = Nothing
                }
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
        [ Html.p [ Attr.id "title" ] [ Html.text "Active Games" ]
        , case model.games of
            Nothing ->
                Html.p [] [ Html.text "Requesting games..." ]

            Just (Err message) ->
                Html.p [] [ Html.text message ]

            Just (Ok games) ->
                viewGamesList games.games
        ]


viewGamesList : List Game -> Html Msg
viewGamesList games =
    case games of
        [] ->
            Html.p [] [ Html.text "No games found." ]

        _ ->
            Html.div [ Attr.id "games" ] (List.map viewGame games)


viewGame : Game -> Html Msg
viewGame game =
    Html.div [ Attr.id "game" ]
        [ Html.div []
            [ Html.span [ Attr.id "name" ] [ Html.text game.name ]
            , Html.span
                [ Attr.id "players" ]
                [ Html.text (String.join ", " game.players) ]
            ]
        , Html.div []
            [ Html.span [ Attr.id "created_at" ] [ timeAgo game.created_at ]
            , Html.div [ Attr.id "buttons" ]
                [ Html.button
                    [ Events.onClick (JoinGame game.guid), Attr.id "join" ]
                    [ Html.text "Join" ]
                , Html.button
                    [ Events.onClick (ViewGame game.guid), Attr.id "view" ]
                    [ Html.text "View" ]
                ]
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
