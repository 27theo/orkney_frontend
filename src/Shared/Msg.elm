module Shared.Msg exposing (Msg(..))

import Shared.Model
import Route.Path


type Msg
    = SignIn Shared.Model.User Route.Path.Path
    | SignOut
    | StartMusic
    | FadeOutMusic
