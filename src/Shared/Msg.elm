module Shared.Msg exposing (Msg(..))

import Shared.Model


type Msg
    = SignIn Shared.Model.User
    | SignOut
    | StartMusic
    | FadeOutMusic
