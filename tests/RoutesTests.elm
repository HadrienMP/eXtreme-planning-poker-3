module RoutesTests exposing (..)

import Expect
import Routes exposing (parseRoute)
import Test exposing (Test, describe, test)
import Test.Utils exposing (inRoom)
import Url


suite : Test
suite =
    describe "Routes"
        [ test "start" <|
            inRoom "dabest" <|
                \room ->
                    "http://localhost:1234/room/dabest"
                        |> Url.fromString
                        |> Maybe.map parseRoute
                        |> Expect.equal (Just room)
        ]
