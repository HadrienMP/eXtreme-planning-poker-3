module Domain.Player exposing (..)

import Domain.Nickname as Nickname exposing (Nickname)
import Json.Decode as Decode
import Json.Encode as Json
import Lib.NonEmptyString as NES exposing (NonEmptyString)


type alias Player =
    { id : NonEmptyString
    , nickname : Nickname
    }


json : Player -> Json.Value
json player =
    Json.object
        [ ( "id", NES.json player.id )
        , ( "nickname", Nickname.json player.nickname )
        ]


decoder : Decode.Decoder Player
decoder =
    Decode.map2 Player
        (Decode.field "id" NES.decoder)
        (Decode.field "nickname" Nickname.decoder)
