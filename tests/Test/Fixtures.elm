module Test.Fixtures exposing (..)

import Domain.Nickname as Nickname
import Domain.Player exposing (Player)
import Domain.PlayerId as PlayerId


pierre : Player
pierre =
    playerNamed "Pierre"


emma : Player
emma =
    playerNamed "Emma"


playerNamed : String -> Player
playerNamed name =
    case ( PlayerId.create <| "id-of-" ++ name, Nickname.create name ) of
        ( Just playerId, Just nickname ) ->
            Player playerId nickname

        _ ->
            Debug.todo "playerNamed fixture should not crash"
