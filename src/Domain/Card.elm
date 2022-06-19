module Domain.Card exposing (Card, fromString, print)


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
