port module Domain.Player exposing (Player, decoder, json, playersIn, sendOut)

import Domain.Nickname as Nickname exposing (Nickname)
import Domain.PlayerId as PlayerId exposing (PlayerId)
import Domain.RoomMessage exposing (RoomMessage)
import Domain.RoomName as RoomName exposing (RoomName)
import Json.Decode as Decode
import Json.Encode as Json


port playerOut : RoomMessage -> Cmd msg


port playersIn : (Json.Value -> msg) -> Sub msg


type alias Player =
    { id : PlayerId
    , nickname : Nickname
    }


sendOut : RoomName -> Player -> Cmd msg
sendOut room =
    json >> RoomMessage (RoomName.print room) >> playerOut


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
