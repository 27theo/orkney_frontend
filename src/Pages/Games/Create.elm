module Pages.Games.Create exposing (Model, Msg, page)

import Api
import Api.Games
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


type alias Model =
    { user : Auth.User
    , name : String
    , submitting : Bool
    , message : Maybe String
    }


init : Auth.User -> () -> ( Model, Effect Msg )
init user () =
    ( { user = user
      , name = ""
      , submitting = False
      , message = Nothing
      }
    , Effect.none
    )



-- UPDATE


type Msg
    = ReturnToGames
    | UserUpdatedInput Field String
    | UserSubmittedForm
    | CreateApiResponded (Result Http.Error Api.Message)


type Field
    = Name


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        ReturnToGames ->
            ( model
            , Effect.pushRoutePath Route.Path.Games
            )

        UserUpdatedInput Name value ->
            ( { model | name = value }
            , Effect.none
            )

        UserSubmittedForm ->
            ( { model | submitting = True }
            , Api.Games.create
                { onResponse = CreateApiResponded
                , token = model.user.token
                , name = model.name
                }
            )

        CreateApiResponded (Ok _) ->
            ( { model | submitting = False }
            , Effect.pushRoutePath Route.Path.Games
            )

        CreateApiResponded (Err _) ->
            ( { model
                | submitting = False
                , message = Just "I couldn't create a game with that name..."
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
    { title = "Create game"
    , body = [ viewPage model ]
    }


viewPage : Model -> Html Msg
viewPage model =
    Html.div [ Attr.id "content" ]
        [ Html.div [ Attr.class "row j-between a-center" ]
            [ Html.p [ Attr.id "title" ] [ Html.text "Create new game" ]
            , Html.button
                [ Events.onClick ReturnToGames
                , Attr.title "Return to the main games page. Progress will be lost."
                ]
                [ Html.text "Return to games" ]
            ]
        , viewForm model
        , case model.message of
            Nothing ->
                Html.text ""

            Just message ->
                Html.p [] [ Html.text message ]
        ]


viewForm : Model -> Html Msg
viewForm model =
    Html.div [ Attr.id "form" ]
        [ Html.form [ Events.onSubmit UserSubmittedForm ]
            [ Html.input
                [ Attr.placeholder "Game name"
                , Attr.type_ "text"
                , Attr.value model.name
                , Events.onInput (UserUpdatedInput Name)
                ]
                []
            , Html.button
                [ Attr.id "submit"
                , Attr.title "Create the game. You will be taken back to the main games page."
                ]
                [ Html.text "Create game" ]
            ]
        ]
