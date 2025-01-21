module Pages.Login exposing (Model, Msg, page)

import Api
import Api.Login
import Api.Signup
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


type alias Login =
    { username : String
    , password : String
    , showPassword : Bool
    , message : String
    , submitting : Bool
    }


type alias Signup =
    { username : String
    , password : String
    , email : String
    , showPassword : Bool
    , message : String
    , submitting : Bool
    }


type alias Model =
    { login : Login
    , signup : Signup
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
    ( { login =
            { username = ""
            , password = ""
            , showPassword = False
            , message = ""
            , submitting = False
            }
      , signup =
            { username = ""
            , password = ""
            , email = ""
            , showPassword = False
            , message = ""
            , submitting = False
            }
      , redirectTo = path
      }
    , Effect.none
    )



-- UPDATE


type Msg
    = LoginUpdatedField LoginField String
    | LoginShowPassword
    | LoginHidePassword
    | LoginSubmittedForm
    | SignupUpdatedField SignupField String
    | SignupSubmittedForm
    | SignupShowPassword
    | SignupHidePassword
    | LoginApiResponded (Result Http.Error Api.TokenResponse)
    | SignupApiResponded (Result Http.Error Api.TokenResponse)


type LoginField
    = Username
    | Password


type SignupField
    = NewUsername
    | NewPassword
    | NewEmail


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    let
        login =
            model.login

        signup =
            model.signup
    in
    case msg of
        LoginUpdatedField Username value ->
            ( { model | login = { login | username = value } }
            , Effect.none
            )

        LoginUpdatedField Password value ->
            ( { model | login = { login | password = value } }
            , Effect.none
            )

        LoginShowPassword ->
            ( { model | login = { login | showPassword = True } }
            , Effect.none
            )

        LoginHidePassword ->
            ( { model | login = { login | showPassword = False } }
            , Effect.none
            )

        LoginSubmittedForm ->
            ( { model | login = { login | submitting = True } }
            , Api.Login.post
                { onResponse = LoginApiResponded
                , username = model.login.username
                , password = model.login.password
                }
            )

        LoginApiResponded (Ok { token }) ->
            ( { model | login = { login | submitting = False } }
            , Effect.signIn
                { token = token
                , username = model.login.username
                }
                model.redirectTo
            )

        LoginApiResponded (Err error) ->
            ( { model
                | login =
                    { login
                        | submitting = False
                        , message = messageFromHttpError error
                    }
              }
            , Effect.none
            )

        SignupUpdatedField NewUsername value ->
            ( { model | signup = { signup | username = value } }
            , Effect.none
            )

        SignupUpdatedField NewPassword value ->
            ( { model | signup = { signup | password = value } }
            , Effect.none
            )

        SignupUpdatedField NewEmail value ->
            ( { model | signup = { signup | email = value } }
            , Effect.none
            )

        SignupSubmittedForm ->
            ( { model | signup = { signup | submitting = True } }
            , Api.Signup.post
                { onResponse = SignupApiResponded
                , username = model.signup.username
                , password = model.signup.password
                , email = model.signup.email
                }
            )

        SignupApiResponded (Ok { token }) ->
            ( { model | signup = { signup | submitting = False } }
            , Effect.signIn
                { token = token
                , username = model.signup.username
                }
                model.redirectTo
            )

        SignupApiResponded (Err _) ->
            ( { model
                | signup =
                    { signup
                        | submitting = False
                        , message = """I couldn't sign you up with those
                        credentials. Your username and email must be unique -
                        please try again."""
                    }
              }
            , Effect.none
            )

        SignupShowPassword ->
            ( { model | signup = { signup | showPassword = True } }
            , Effect.none
            )

        SignupHidePassword ->
            ( { model | signup = { signup | showPassword = False } }
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
        , viewLoginForm model
        , Html.p [] [ Html.text model.login.message ]
        , Html.p [ Attr.id "signup" ] [ Html.text "Alternatively, sign up:" ]
        , viewSignupForm model
        , Html.p [] [ Html.text model.signup.message ]
        ]


viewLoginForm : Model -> Html Msg
viewLoginForm model =
    Html.div [ Attr.id "form" ]
        [ Html.form [ Events.onSubmit LoginSubmittedForm ]
            [ Html.input
                [ Attr.placeholder "Username"
                , Attr.type_ "username"
                , Attr.value model.login.username
                , Events.onInput (LoginUpdatedField Username)
                ]
                []
            , Html.input
                [ Attr.placeholder "Password"
                , Attr.type_
                    (if model.login.showPassword then
                        "text"

                     else
                        "password"
                    )
                , Attr.value model.login.password
                , Events.onInput (LoginUpdatedField Password)
                ]
                []
            , Html.div [ Attr.id "lcontrols" ]
                [ Html.div []
                    [ Html.span [] [ Html.text "show password" ]
                    , Html.input
                        [ Attr.type_ "checkbox"
                        , Attr.checked model.login.showPassword
                        , Events.onClick
                            (if model.login.showPassword then
                                LoginHidePassword

                             else
                                LoginShowPassword
                            )
                        ]
                        []
                    ]
                , Html.button
                    [ Attr.disabled model.login.submitting
                    , Attr.title "Log in."
                    ]
                    [ Html.text "Log in" ]
                ]
            ]
        ]


viewSignupForm : Model -> Html Msg
viewSignupForm model =
    Html.div [ Attr.id "form" ]
        [ Html.form [ Events.onSubmit SignupSubmittedForm ]
            -- https://stackoverflow.com/a/23234498
            [ Html.input [ Attr.type_ "text", Attr.style "display" "none" ] []
            , Html.input [ Attr.type_ "password", Attr.style "display" "none" ] []
            , Html.input
                [ Attr.placeholder "New username"
                , Attr.value model.signup.username
                , Events.onInput (SignupUpdatedField NewUsername)
                ]
                []
            , Html.input
                [ Attr.placeholder "New email"
                , Attr.type_ "email"
                , Attr.value model.signup.email
                , Events.onInput (SignupUpdatedField NewEmail)
                ]
                []
            , Html.input
                [ Attr.placeholder "Password"
                , Attr.type_
                    (if model.signup.showPassword then
                        "text"

                     else
                        "password"
                    )
                , Attr.value model.signup.password
                , Events.onInput (SignupUpdatedField NewPassword)
                ]
                []
            , Html.div [ Attr.id "lcontrols" ]
                [ Html.div []
                    [ Html.span [] [ Html.text "show password" ]
                    , Html.input
                        [ Attr.type_ "checkbox"
                        , Attr.checked model.signup.showPassword
                        , Events.onClick
                            (if model.signup.showPassword then
                                SignupHidePassword

                             else
                                SignupShowPassword
                            )
                        ]
                        []
                    ]
                , Html.button
                    [ Attr.disabled model.signup.submitting
                    , Attr.title "Sign up. You will be automatically logged in and redirected."
                    ]
                    [ Html.text "Sign up" ]
                ]
            ]
        ]
