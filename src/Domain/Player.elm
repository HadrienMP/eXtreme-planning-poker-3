port module Domain.Player exposing (Player, decoder, json, playersIn)

import Domain.Nickname as Nickname exposing (Nickname)
import Domain.PlayerId as PlayerId exposing (PlayerId)
import Json.Decode as Decode
import Json.Encode as Json


port playersIn : (Json.Value -> msg) -> Sub msg


type alias Player =
    { id : PlayerId
    , nickname : Nickname
    }


json : Player -> Json.Value
json player =
    Json.object
        [ ( "id", PlayerId.json player.id )
        , ( "nickname", Nickname.json player.nickname )
        ]


decoder : Decode.Decoder Player
decoder =
    Decode.map2 Player
        (Decode.field "id" PlayerId.decoder)
        (Decode.field "nickname" Nickname.decoder)
