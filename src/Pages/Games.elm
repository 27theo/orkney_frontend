module Pages.Games exposing (Model, Msg, page)

import Api
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


type Message
    = Failure String
    | Success String


type alias Model =
    { games : Maybe (Result String GamesList)
    , user : Auth.User
    , message : Maybe Message
    }


init : Auth.User -> () -> ( Model, Effect Msg )
init user () =
    ( { user = user
      , games = Nothing
      , message = Nothing
      }
    , Effect.sendMsg ApiGetGames
    )



-- UPDATE


type Msg
    = ApiGetGames
    | ApiRespondedGames (Result Http.Error GamesList)
    | JoinGame String
    | JoinedGame (Result Http.Error Api.Message)
    | LeaveGame String
    | LeftGame (Result Http.Error Api.Message)
    | ViewGame String


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        ApiGetGames ->
            ( model
            , Api.Games.getAll
                { onResponse = ApiRespondedGames
                , token = model.user.token
                }
            )

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
            , Api.Games.join
                { onResponse = JoinedGame
                , token = model.user.token
                , guid = guid
                }
            )

        JoinedGame (Ok _) ->
            ( { model | message = Just (Success "Joined game!") }
            , Effect.sendMsg ApiGetGames
            )

        JoinedGame (Err _) ->
            ( { model | message = Just (Failure "Failed to join game...") }
            , Effect.none
            )

        LeaveGame guid ->
            ( model
            , Api.Games.leave
                { onResponse = LeftGame
                , token = model.user.token
                , guid = guid
                }
            )

        LeftGame (Ok _) ->
            ( { model | message = Just (Success "Left game!") }
            , Effect.sendMsg ApiGetGames
            )

        LeftGame (Err _) ->
            ( { model | message = Just (Failure "Failed to leave game...") }
            , Effect.none
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
    { title = "Games"
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
                viewGamesList model games.games
        ]


viewGamesList : Model -> List Game -> Html Msg
viewGamesList model games =
    case games of
        [] ->
            Html.p [] [ Html.text "No games found." ]

        _ ->
            Html.div [ Attr.id "games" ] (List.map (viewGame model) games)


viewGame : Model -> Game -> Html Msg
viewGame model game =
    Html.div [ Attr.id "game" ]
        [ Html.div []
            [ Html.span [ Attr.id "name" ] [ Html.text game.name ]
            , viewPlayerList model game
            ]
        , Html.div []
            [ Html.span [ Attr.id "created_at" ] [ timeAgo game ]
            , viewGameButtons model game
            ]
        ]


viewPlayerList : Model -> Game -> Html Msg
viewPlayerList model game =
    let
        players =
            List.map
                (\u ->
                    Html.span
                        [ Attr.id
                            (if model.user.username == u then
                                "user"

                             else
                                ""
                            )
                        ]
                        [ Html.text u ]
                )
                game.players
                |> List.intersperse (Html.span [] [ Html.text ", " ])
    in
    Html.span
        [ Attr.id "players" ]
        [ Html.span [] players
        ]


viewGameButtons : Model -> Game -> Html Msg
viewGameButtons model game =
    let
        joinLeaveButton : Html Msg
        joinLeaveButton =
            case
                ( List.member model.user.username game.players
                , List.length game.players > 1
                , game.owner == model.user.username
                )
            of
                ( True, True, False ) ->
                    Html.button
                        [ Events.onClick (LeaveGame game.guid), Attr.id "join" ]
                        [ Html.text "Leave" ]

                ( False, _, _ ) ->
                    Html.button
                        [ Events.onClick (JoinGame game.guid), Attr.id "join" ]
                        [ Html.text "Join" ]

                _ ->
                    Html.text ""
    in
    Html.div [ Attr.id "buttons" ]
        [ joinLeaveButton
        , Html.button
            [ Events.onClick (ViewGame game.guid), Attr.id "view" ]
            [ Html.text "View" ]
        ]


timeAgo : Game -> Html Msg
timeAgo game =
    case String.toInt game.created_at of
        Just e ->
            Html.span []
                [ Html.node "time-ago"
                    [ Attr.attribute "epoch" (String.fromInt e) ]
                    []
                , Html.span [ Attr.id "owner" ] [ Html.text game.owner ]
                ]

        Nothing ->
            Html.span [] [ Html.text "(error)" ]
