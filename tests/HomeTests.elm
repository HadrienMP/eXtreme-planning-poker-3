module HomeTests exposing (..)

import Expect
import ProgramTest exposing (..)
import Routes
import Test exposing (..)
import TestSetup exposing (..)


all : Test
all =
    describe "Home"
        [ test "Clicking on join redirects you to the room you chose" <|
            \() ->
                startAppOn Routes.Home
                    |> writeInField { id = "room", label = "Room", value = "dabest" }
                    |> writeInField { id = "nickname", label = "Nickname", value = "Joba" }
                    |> clickButton "Join"
                    |> expectBrowserUrl (Expect.equal <| baseUrl ++ "/room/dabest")
        ]
