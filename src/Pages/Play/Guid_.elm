module Pages.Play.Guid_ exposing (Model, Msg, page)

import Api.Games exposing (Game, PlayerState, State)
import Auth
import Effect exposing (Effect)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Http
import Page exposing (Page)
import Route exposing (Route)
import Route.Path
import Shared
import View exposing (View)


page : Auth.User -> Shared.Model -> Route { guid : String } -> Page Model Msg
page user _ route =
    Page.new
        { init = init user route
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- INIT


type alias Model =
    { token : String
    , guid : String
    , game : Maybe Game
    }


init : Auth.User -> Route { guid : String } -> () -> ( Model, Effect Msg )
init user route () =
    ( { token = user.token
      , guid = route.params.guid
      , game = Nothing
      }
    , Api.Games.getSingle
        { onResponse = ApiRespondedGame
        , token = user.token
        , guid = route.params.guid
        }
    )



-- UPDATE


type Msg
    = ApiRespondedGame (Result Http.Error Game)
    | ReturnToGames


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        ApiRespondedGame (Ok game) ->
            ( { model | game = Just game }
            , Effect.none
            )

        ApiRespondedGame (Err _) ->
            ( model
            , Effect.none
            )

        ReturnToGames ->
            ( model
            , Effect.pushRoutePath Route.Path.Games
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title =
        (case model.game of
            Nothing ->
                "Loading game..."

            Just g ->
                "Playing '" ++ g.name ++ "'"
        )
            ++ " | Lords of Orkney"
    , body = [ viewBody model ]
    }


viewBody : Model -> Html Msg
viewBody model =
    Html.div [ Attr.id "play" ] <|
        case model.game of
            Nothing ->
                []

            Just g ->
                [ viewHeader g
                , viewBoard g model
                ]


viewHeader : Game -> Html Msg
viewHeader game =
    Html.div [ Attr.id "header" ]
        [ Html.p [ Attr.id "name" ]
            [ Html.text game.name ]
        , Html.button
            [ Events.onClick ReturnToGames ]
            [ Html.text "Return to all games" ]
        ]


viewBoard : Game -> Model -> Html Msg
viewBoard game _ =
    let
        _ =
            Debug.log "state" game.state
    in
    Html.div [ Attr.id "board" ]
        [ Html.p [] [ viewState game.state ]
        ]


viewState : State -> Html Msg
viewState state =
    let
        viewPlayerState : PlayerState -> String
        viewPlayerState ps =
            String.concat [ "Name: ", ps.username, ", gold: ", String.fromInt ps.gold ]
    in
    List.map viewPlayerState state.player_states
        |> List.map (\s -> Html.div [ Attr.id "playerState" ] [ Html.text s ])
        |> Html.div [ Attr.id "state" ]
