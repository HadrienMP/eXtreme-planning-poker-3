port module IO.VoteIO exposing (..)

import Json.Decode as Decode
import Json.Encode as Json
import Lib.NonEmptyString as NES exposing (NonEmptyString)
import Domain.Card as Card exposing (Card)

type alias VoteIO =
    { player : NonEmptyString 
    , card : Card 
    }


json : VoteIO -> Json.Value
json vote =
    Json.object
        [ ( "player", vote.player |> NES.print |> Json.string )
        , ( "card", vote.card |> Card.print |> Json.string )
        ]


decoder : Decode.Decoder VoteIO
decoder =
    Decode.map2 VoteIO 
        (Decode.field "player" NES.decoder)
        (Decode.field "card" Card.decoder)
