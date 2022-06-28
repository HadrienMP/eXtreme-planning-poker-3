module Utils exposing (..)

import Domain.RoomName
import Expect
import Routes


inRoom : String -> (Routes.Route -> Expect.Expectation) -> () -> Expect.Expectation
inRoom room testF =
    withMaybe (Domain.RoomName.fromString room) (Routes.Room >> testF)


withMaybe : Maybe a -> (a -> Expect.Expectation) -> () -> Expect.Expectation
withMaybe it testF _ =
    case it of
        Just b ->
            testF b

        Nothing ->
            Expect.fail <| "Expected a value to start the test but got " ++ Debug.toString it


withMaybe2 : ( Maybe a, Maybe b ) -> (( a, b ) -> Expect.Expectation) -> () -> Expect.Expectation
withMaybe2 tuple testF _ =
    case tuple of
        ( Just a, Just b ) ->
            testF ( a, b )

        _ ->
            Expect.fail <| "Expected values to start the test but got " ++ Debug.toString tuple


withMaybe3 : ( Maybe a, Maybe b, Maybe c ) -> (( a, b, c ) -> Expect.Expectation) -> () -> Expect.Expectation
withMaybe3 tuple testF _ =
    case tuple of
        ( Just a, Just b, Just c ) ->
            testF ( a, b, c )

        _ ->
            Expect.fail <| "Expected values to start the test but got " ++ Debug.toString tuple
