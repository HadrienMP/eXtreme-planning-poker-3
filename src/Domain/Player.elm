port module Domain.Player exposing (Player, decoder, json, playerOut, playersIn)

import Domain.Nickname as Nickname exposing (Nickname)
import Domain.PlayerId as PlayerId exposing (PlayerId)
import Json.Decode as Decode
import Json.Encode as Json


port playerOut : Json.Value -> Cmd msg


port playersIn : (Json.Value -> msg) -> Sub msg


type alias Player =
    { id : PlayerId
    , nickname : Nickname
    }


json : Player -> Json.Value
json it =
    Json.object
        [ ( "id", PlayerId.json it.id )
        , ( "nickname", Nickname.json it.nickname )
        ]


decoder : Decode.Decoder Player
decoder =
    Decode.map2 Player
        (Decode.field "id" PlayerId.decoder)
        (Decode.field "nickname" Nickname.decoder)
