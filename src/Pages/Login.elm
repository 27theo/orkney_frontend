module Pages.Login exposing (Model, Msg, page)

import Api.Login
import Effect exposing (Effect)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events
import Http
import Layouts
import Page exposing (Page)
import Route exposing (Route)
import Shared
import View exposing (View)


page : Shared.Model -> Route () -> Page Model Msg
page _ _ =
    Page.new
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
        |> Page.withLayout toLayout


toLayout : Model -> Layouts.Layout Msg
toLayout _ =
    Layouts.Navbar
        { user = Nothing
        }



-- INIT


type alias Model =
    { username : String
    , password : String
    , message : String
    , submitting : Bool
    }


init : () -> ( Model, Effect Msg )
init () =
    ( { username = ""
      , password = ""
      , message = ""
      , submitting = False
      }
    , Effect.none
    )



-- UPDATE


type Msg
    = UserUpdatedInput Field String
    | UserSubmittedForm
    | LoginApiResponded (Result Http.Error Api.Login.TokenResponse)


type Field
    = Username
    | Password


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        UserUpdatedInput Username value ->
            ( { model | username = value }
            , Effect.none
            )

        UserUpdatedInput Password value ->
            ( { model | password = value }
            , Effect.none
            )

        UserSubmittedForm ->
            ( { model | submitting = True }
            , Api.Login.post
                { onResponse = LoginApiResponded
                , username = model.username
                , password = model.password
                }
            )

        LoginApiResponded (Ok { token }) ->
            ( { model | submitting = False }
            , Effect.signIn
                { token = token
                , username = model.username
                }
            )

        LoginApiResponded (Err error) ->
            ( { model
                | submitting = False
                , message = messageFromHttpError error
              }
            , Effect.none
            )


messageFromHttpError : Http.Error -> String
messageFromHttpError error =
    case error of
        Http.BadUrl _ ->
            """This should never happen - the login URL has gone bad. Please
            try again. If the problem persists, let Theo know."""

        Http.Timeout ->
            """The login request timed out. Please try again! If this problem
            persists, let Theo know."""

        Http.NetworkError ->
            """A network error occured. Are you connected to the internet? If
            you are, try again. If the problem persists, let Theo know - the
                game server could be down."""

        Http.BadBody _ ->
            """This should never happen - the request body has gone bad. Please
            try again. If the problem persists, let Theo know."""

        Http.BadStatus code ->
            if code == 401 then
                """I couldn't log you in with that username and password.
                Double check that you have entered them correctly."""

            else
                [ "There seems to be a problem with the game server - it's responded with status code "
                , String.fromInt code
                , ". Try logging in again. If this problem persists, let Theo know."
                ]
                    |> String.concat



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Login"
    , body = [ viewPage model ]
    }


viewPage : Model -> Html Msg
viewPage model =
    Html.div [ Attr.id "content" ]
        [ Html.h1 [] [ Html.text "Log in" ]
        , viewForm model
        , Html.p [] [ Html.text model.message ]
        ]


viewForm : Model -> Html Msg
viewForm model =
    Html.form [ Html.Events.onSubmit UserSubmittedForm ]
        [ viewFormInput Username model.username
        , viewFormInput Password model.password
        , Html.button
            [ Attr.disabled model.submitting ]
            [ Html.text "Log in" ]
        ]


viewFormInput : Field -> String -> Html Msg
viewFormInput field value =
    let
        label =
            case field of
                Username ->
                    "Username"

                Password ->
                    "Password"
    in
    let
        type_ =
            case field of
                Username ->
                    "username"

                Password ->
                    "password"
    in
    Html.div
        []
        [ Html.label [] [ Html.text label ]
        , Html.div []
            [ Html.input
                [ Attr.type_ type_
                , Attr.value value
                , Html.Events.onInput (UserUpdatedInput field)
                ]
                []
            ]
        ]
