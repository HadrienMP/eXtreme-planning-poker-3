module Domain.Nickname exposing (Nickname, decoder, fromString, json, print)

import Json.Decode as Decode
import Json.Encode as Json
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


getValue : Nickname -> NES.NonEmptyString
getValue nickname =
    case nickname of
        Nickname nes ->
            nes


json : Nickname -> Json.Value
json =
    getValue >> NES.json


decoder : Decode.Decoder Nickname
decoder =
    NES.decoder |> Decode.map Nickname
