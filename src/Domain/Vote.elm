port module Domain.Vote exposing (..)

import Domain.Card as Card exposing (Card)
import Domain.PlayerId as PlayerId exposing (PlayerId)
import Domain.RoomName as RoomName exposing (RoomName)
import Json.Decode as Decode
import Json.Encode as Json


port votesOut : VoteOut -> Cmd msg


type alias VoteOut =
    { room : String
    , vote : Json.Value
    }


type alias Vote =
    { player : PlayerId
    , card : Maybe Card
    }


sendOut : RoomName -> Vote -> Cmd msg
sendOut room =
    json >> VoteOut (RoomName.print room) >> votesOut


json : Vote -> Json.Value
json vote =
    Json.object
        [ ( "player", vote.player |> PlayerId.print |> Json.string )
        , ( "card", vote.card |> Maybe.map (Card.print >> Json.string) |> Maybe.withDefault Json.null )
        ]


decoder : Decode.Decoder Vote
decoder =
    Decode.map2 Vote
        (Decode.field "player" PlayerId.decoder)
        (Decode.maybe <| Decode.field "card" Card.decoder)
