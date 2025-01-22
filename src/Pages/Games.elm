module Pages.Games exposing (Model, Msg, page)

import Api
import Api.Games exposing (Game, GamesList)
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
    | DeleteGame String
    | DeletedGame (Result Http.Error Api.Message)
    | CreateGame
    | PlayGame String
    | StartGame String
    | StartedGame (Result Http.Error Api.Message)


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

        DeleteGame guid ->
            ( model
            , Api.Games.delete
                { onResponse = LeftGame
                , token = model.user.token
                , guid = guid
                }
            )

        DeletedGame (Ok _) ->
            ( { model | message = Just (Success "Left game!") }
            , Effect.sendMsg ApiGetGames
            )

        DeletedGame (Err _) ->
            ( { model | message = Just (Failure "Failed to leave game...") }
            , Effect.none
            )

        CreateGame ->
            ( model
            , Effect.pushRoutePath Route.Path.Games_Create
            )

        PlayGame guid ->
            ( model
            , Effect.pushRoutePath (Route.Path.Play_Guid_ { guid = guid })
            )

        StartGame guid ->
            ( model
            , Api.Games.activate
                { onResponse = StartedGame
                , token = model.user.token
                , guid = guid
                }
            )

        StartedGame (Ok _) ->
            ( model
            , Effect.sendMsg ApiGetGames
            )

        StartedGame (Err _) ->
            ( { model | message = Just (Success "Could not activate game. Please try again") }
            , Effect.sendMsg ApiGetGames
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
        [ Html.div [ Attr.class "row j-between a-center" ]
            [ Html.p [ Attr.id "title" ] [ Html.text "Active Games" ]
            , Html.button
                [ Events.onClick CreateGame
                , Attr.id "create"
                , Attr.title "Navigate to a new page for game creation."
                ]
                [ Html.text "Create new game" ]
            ]
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
            let
                yourOngoing =
                    List.filter
                        (\g ->
                            g.is_active
                                && List.member model.user.username g.players
                        )
                        games
            in
            let
                yourGames =
                    List.filter
                        (\g ->
                            not g.is_active
                                && List.member model.user.username g.players
                        )
                        games
            in
            let
                joinableGames =
                    List.filter
                        (\g ->
                            not g.is_active
                                && not (List.member model.user.username g.players)
                        )
                        games
            in
            let
                others =
                    List.filter
                        (\g ->
                            g.is_active
                                && not (List.member model.user.username g.players)
                        )
                        games
            in
            Html.div [ Attr.id "games" ]
                (List.concat
                    [ viewGameSet model yourOngoing "Ongoing games"
                    , viewGameSet model yourGames "Ready to start"
                    , viewGameSet model joinableGames "Joinable"
                    , viewGameSet model others "Other players' ongoing games"
                    ]
                )


viewGameSet : Model -> List Game -> String -> List (Html Msg)
viewGameSet model games header =
    case games of
        [] ->
            [ Html.text "" ]

        _ ->
            List.append
                [ Html.p []
                    [ Html.text header
                    ]
                ]
                (List.map (viewGame model) games)


viewGame : Model -> Game -> Html Msg
viewGame model game =
    Html.div [ Attr.id "game" ]
        [ Html.div []
            [ Html.span [ Attr.id "name" ] [ Html.text game.name ]
            , viewPlayerList model game
            ]
        , Html.div []
            [ Html.span [ Attr.id "created_at" ] [ timeAgo model game ]
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
                        [ Attr.classList
                            [ ( "user", model.user.username == u ) ]
                        ]
                        [ Html.text u ]
                )
                game.players
                |> List.intersperse (Html.text ", ")
    in
    Html.span
        [ Attr.id "players" ]
        [ Html.span [] players
        ]


viewGameButtons : Model -> Game -> Html Msg
viewGameButtons model game =
    Html.div [ Attr.id "buttons" ]
        [ joinLeaveDelete model game
        , playWatchStart model game
        ]


joinLeaveDelete : Model -> Game -> Html Msg
joinLeaveDelete model game =
    case
        [ List.member model.user.username game.players
        , game.owner == model.user.username
        , List.length game.players > 1
        , game.is_active
        ]
    of
        [ True, False, True, False ] ->
            Html.button
                [ Events.onClick (LeaveGame game.guid)
                , Attr.title "Leave the game. As the game is still inactive, you can re-join."
                ]
                [ Html.text "Leave" ]

        [ False, _, _, False ] ->
            Html.button
                [ Events.onClick (JoinGame game.guid)
                , Attr.id "join"
                , Attr.title "Join the game."
                ]
                [ Html.text "Join" ]

        [ _, True, _, False ] ->
            -- TODO: Confirm deletion upon click
            Html.button
                [ Events.onClick (DeleteGame game.guid)
                , Attr.id "delete"
                , Attr.title "Delete the game. This is irreversible."
                ]
                [ Html.text "Delete" ]

        _ ->
            Html.text ""


playWatchStart : Model -> Game -> Html Msg
playWatchStart model game =
    case
        ( List.member model.user.username game.players
        , game.is_active
        , model.user.username == game.owner
        )
    of
        ( True, True, _ ) ->
            -- TODO
            Html.button
                [ Attr.id "play"
                , Attr.title "Navigate to the board in order to play the game."
                , Events.onClick (PlayGame game.guid)
                ]
                [ Html.text "Play" ]

        ( False, True, _ ) ->
            -- TODO
            Html.button
                [ Attr.id "watch"
                , Attr.title "Spectate the game."
                ]
                [ Html.text "Watch" ]

        ( _, False, True ) ->
            -- TODO
            Html.button
                [ Attr.id "start"
                , Attr.title "Start the game. Players will no longer be able to join."
                , Events.onClick (StartGame game.guid)
                ]
                [ Html.text "Start" ]

        _ ->
            Html.text ""


timeAgo : Model -> Game -> Html Msg
timeAgo model game =
    case String.toInt game.created_at of
        Just e ->
            Html.span []
                [ Html.node "time-ago"
                    [ Attr.attribute "epoch" (String.fromInt e) ]
                    []
                , Html.span
                    [ Attr.id "owner"
                    , Attr.classList [ ( "user", model.user.username == game.owner ) ]
                    ]
                    [ Html.text game.owner ]
                ]

        Nothing ->
            Html.span [] [ Html.text "(error)" ]
