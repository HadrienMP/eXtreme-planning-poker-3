module Test.Fixtures exposing (..)

import Domain.Nickname as Nickname
import Domain.Player exposing (Player)
import Domain.PlayerId as PlayerId


pierre : Maybe Player
pierre =
    playerNamed "Pierre"


emma : Maybe Player
emma =
    playerNamed "Emma"


playerNamed : String -> Maybe Player
playerNamed name =
    case ( PlayerId.create <| "id-of-" ++ name, Nickname.create name ) of
        ( Just playerId, Just nickname ) ->
            Just <| Player playerId nickname

        _ ->
            Nothing
