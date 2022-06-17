module RoomTests exposing (..)

import ProgramTest exposing (..)
import Routes
import Test exposing (..)
import Test.Html.Selector as Selector
import TestSetup exposing (..)
import Utils exposing (inRoom)


all : Test
all =
    describe "Room"
        [ test "the room name is displayed on the page" <|
            inRoom "dabest" <|
                \room ->
                    startAppOn room
                        |> expectViewHas [ Selector.text "room: dabest" ]
        , test "spaces are allowed in the room name" <|
            inRoom "dabest heyhey" <|
                \room ->
                    startAppOn room
                        |> expectViewHas [ Selector.text "room: dabest heyhey" ]
        , test "the current username is displayed on the page" <|
            \_ ->
                startAppOn Routes.Home
                    |> writeInField { id = "room", label = "Room", value = "dabest" }
                    |> writeInField { id = "nickname", label = "Nickname", value = "Joba" }
                    |> clickButton "Join"
                    |> ensureViewHas [ Selector.text "deck of Joba" ]
                    |> done
        , test "a guest arriving in a room is displayed the nickname field" <|
            inRoom "dabest heyhey" <|
                \room ->
                    startAppOn room
                        |> ensureViewHasNot [ Selector.text "deck of Joba" ]
                        |> writeInField { id = "nickname", label = "Nickname", value = "Jo" }
                        |> writeInField { id = "nickname", label = "Nickname", value = "ba" }
                        |> clickButton "Join"
                        |> ensureViewHas [ Selector.text "deck of ba" ]
                        |> done
        ]
