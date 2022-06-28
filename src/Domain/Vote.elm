module Domain.Vote exposing (..)

import Domain.Card as Card exposing (Card)
import Domain.PlayerId as PlayerId exposing (PlayerId)
import Json.Decode as Decode
import Json.Encode as Json


type alias Vote =
    { player : PlayerId
    , card : Maybe Card
    }


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
