module Pages.Login exposing (Model, Msg, page)

import Api.Login
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


page : Shared.Model -> Route () -> Page Model Msg
page _ route =
    Page.new
        { init = init route
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
    , showPassword : Bool
    , message : String
    , submitting : Bool
    , redirectTo : Route.Path.Path
    }


init : Route () -> () -> ( Model, Effect Msg )
init route () =
    let
        path =
            case
                Dict.get "from" route.query
                    |> Maybe.andThen Route.Path.fromString
            of
                Just p ->
                    p

                _ ->
                    Route.Path.Games
    in
    ( { username = ""
      , password = ""
      , showPassword = False
      , message = ""
      , submitting = False
      , redirectTo = path
      }
    , Effect.none
    )



-- UPDATE


type Msg
    = UserUpdatedInput Field String
    | ShowPassword
    | HidePassword
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

        ShowPassword ->
            ( { model | showPassword = True }
            , Effect.none
            )

        HidePassword ->
            ( { model | showPassword = False }
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
                model.redirectTo
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
        [ Html.p [ Attr.id "title" ] [ Html.text "Log in" ]
        , viewForm model
        , Html.p [] [ Html.text model.message ]
        ]


viewForm : Model -> Html Msg
viewForm model =
    Html.div [ Attr.id "form" ]
        [ Html.form [ Events.onSubmit UserSubmittedForm ]
            [ Html.input
                [ Attr.placeholder "Username"
                , Attr.type_ "username"
                , Attr.value model.username
                , Events.onInput (UserUpdatedInput Username)
                ]
                []
            , Html.input
                [ Attr.placeholder "Password"
                , Attr.type_
                    (if model.showPassword then
                        "text"

                     else
                        "password"
                    )
                , Attr.value model.password
                , Events.onInput (UserUpdatedInput Password)
                ]
                []
            , Html.div [ Attr.id "lcontrols" ]
                [ Html.div []
                    [ Html.span [] [ Html.text "show password" ]
                    , Html.input
                        [ Attr.type_ "checkbox"
                        , Attr.checked model.showPassword
                        , Events.onClick
                            (if model.showPassword then
                                HidePassword

                             else
                                ShowPassword
                            )
                        ]
                        []
                    ]
                , Html.button
                    [ Attr.disabled model.submitting
                    , Attr.title "Log in."
                    ]
                    [ Html.text "Log in" ]
                ]
            ]
        ]
