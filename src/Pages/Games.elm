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
    { games : Maybe (Result String Api.Games.GamesList)
    , user : Auth.User
    }


init : Auth.User -> () -> ( Model, Effect Msg )
init user () =
    ( { user = user
      , games = Nothing
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

        ApiRespondedGames (Ok games) ->
            ( { model | games = Just (Ok games) }
            , Effect.none
            )

        ApiRespondedGames (Err _) ->
            ( { model
                | games = Just (Err "Failed to fetch games list from API. Please try again.")
              }
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
        [ Html.p [ Attr.id "title" ] [ Html.text "Active Games" ]
        , case model.games of
            Nothing ->
                Html.p [] [ Html.text "Requesting games..." ]

            Just (Err message) ->
                Html.p [] [ Html.text message ]

            Just (Ok games) ->
                viewGamesList games.games
        ]


viewGamesList : List Api.Games.Game -> Html Msg
viewGamesList games =
    case games of
        [] ->
            Html.p [] [ Html.text "No games found." ]

        _ ->
            Html.div [ Attr.id "games" ] (List.map viewGame games)


viewGame : Api.Games.Game -> Html Msg
viewGame game =
    Html.div [ Attr.id "game" ]
        [ Html.div []
            [ Html.span [ Attr.id "name" ] [ Html.text game.name ]
            , Html.span [ Attr.id "players" ] [ Html.text (String.join ", " game.players) ]
            ]
        , Html.div []
            [ Html.span [ Attr.id "created_at" ] [ timeAgo game.created_at ]
            , Html.button [ Attr.id "join" ] [ Html.text "Join" ]
            ]
        ]


timeAgo : String -> Html Msg
timeAgo epoch =
    case String.toInt epoch of
        Just e ->
            Html.node "time-ago" [ Attr.attribute "epoch" (String.fromInt (e * 1000)) ] []

        Nothing ->
            Html.span [] [ Html.text "(could not convert time)" ]
