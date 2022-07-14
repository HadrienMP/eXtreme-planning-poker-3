port module Domain.PlayerId exposing (..)

import Json.Decode as Decode
import Json.Encode as Json
import Lib.NonEmptyString as NES exposing (NonEmptyString)


port playerIdIn : (Decode.Value -> msg) -> Sub msg


type PlayerId
    = PlayerId NonEmptyString


create : String -> Maybe PlayerId
create =
    NES.create >> Maybe.map PlayerId


getValue : PlayerId -> NonEmptyString
getValue id =
    case id of
        PlayerId value ->
            value


print : PlayerId -> String
print =
    getValue >> NES.print


json : PlayerId -> Json.Value
json =
    getValue >> NES.json


decode : Decode.Value -> Maybe PlayerId
decode it =
    it
        |> Decode.decodeValue decoder
        |> Result.toMaybe


decoder : Decode.Decoder PlayerId
decoder =
    NES.decoder |> Decode.map PlayerId
