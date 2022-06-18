module Nickname exposing (..)

import Lib.NonEmptyString as NES


type Nickname
    = Nickname NES.NonEmptyString


fromString : String -> Maybe Nickname
fromString raw =
    NES.create raw |> Maybe.map Nickname


print : Nickname -> String
print nickname =
    case nickname of
        Nickname nes ->
            NES.print nes
