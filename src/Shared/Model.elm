module Shared.Model exposing (Model, User)


type alias User =
    { token : String
    , username : String
    }


type alias Model =
    { user : Maybe User
    , music : Bool
    }
