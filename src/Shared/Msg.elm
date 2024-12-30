module Shared.Msg exposing (Msg(..))


type Msg
    = SignIn { token : String }
    | SignOut
