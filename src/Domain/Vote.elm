module Domain.Vote exposing (..)

import Domain.Card as Card exposing (Card)
import Json.Decode as Decode
import Json.Encode as Json
import Lib.NonEmptyString as NES exposing (NonEmptyString)


type alias Vote =
    { player : NonEmptyString
    , card : Card
    }


json : Vote -> Json.Value
json vote =
    Json.object
        [ ( "player", vote.player |> NES.print |> Json.string )
        , ( "card", vote.card |> Card.print |> Json.string )
        ]


decoder : Decode.Decoder Vote
decoder =
    Decode.map2 Vote
        (Decode.field "player" NES.decoder)
        (Decode.field "card" Card.decoder)
