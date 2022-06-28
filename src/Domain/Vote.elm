module Domain.Vote exposing (..)

import Domain.Card as Card exposing (Card)
import Json.Decode as Decode
import Json.Encode as Json
import Lib.NonEmptyString as NES exposing (NonEmptyString)


type alias Vote =
    { player : NonEmptyString
    , card : Maybe Card
    }


json : Vote -> Json.Value
json vote =
    Json.object
        [ ( "player", vote.player |> NES.print |> Json.string )
        , ( "card", vote.card |> Maybe.map (Card.print >> Json.string) |> Maybe.withDefault Json.null )
        ]


decoder : Decode.Decoder Vote
decoder =
    Decode.map2 Vote
        (Decode.field "player" NES.decoder)
        (Decode.maybe <| Decode.field "card" Card.decoder)
