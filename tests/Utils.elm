module Utils exposing (..)

import Domain.RoomName
import Expect
import Routes


inRoom : String -> (Routes.Route -> Expect.Expectation) -> (() -> Expect.Expectation)
inRoom room test =
    room
        |> Domain.RoomName.fromString
        |> Maybe.map Routes.Room
        |> Maybe.map (\route -> \_ -> test route)
        |> Maybe.withDefault (\_ -> Expect.fail "dabest was rejected as a room name")


withMaybe : Maybe a -> (a -> Expect.Expectation) -> () -> Expect.Expectation
withMaybe it test _ =
    case it of
        Just b ->
            test b

        Nothing ->
            Expect.fail "Expected a value to start the test"
