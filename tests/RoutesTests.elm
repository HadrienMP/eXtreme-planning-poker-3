module RoutesTests exposing (..)

import Expect
import Routes exposing (parseRoute)
import Test exposing (Test, describe, test)
import Url


suite : Test
suite =
    describe "Routes"
        [ test "start" <|
            \_ ->
                "http://localhost:1234/room/dabest"
                    |> Url.fromString
                    |> Maybe.map parseRoute
                    |> Expect.equal (Just <| Routes.Room "dabest")
        ]
