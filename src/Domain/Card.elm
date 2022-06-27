module Domain.Card exposing (Card, decoder, fromString, print)

import Json.Decode as Decode


type Card
    = Card String


fromString : String -> Card
fromString value =
    Card value


print : Card -> String
print card =
    case card of
        Card value ->
            value


decoder : Decode.Decoder Card
decoder =
    Decode.string
        |> Decode.map Card
