module Shared.Model exposing (Model, User)


type alias User =
    { token : String
    }


type alias Model =
    { user : Maybe User
    }
