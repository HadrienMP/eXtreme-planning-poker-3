module RoomTests exposing (..)

import Effect exposing (Effect)
import Main
import ProgramTest exposing (..)
import Routes
import Test exposing (..)
import Test.Html.Selector as Selector
import TestSetup exposing (..)
import Utils exposing (inRoom)


all : Test
all =
    describe "Room"
        [ test "displays the room name" <|
            inRoom "dabest" <|
                \room ->
                    startAppOn room
                        |> expectViewHas [ Selector.text "room: dabest" ]
        , test "displays the deck of the player" <|
            \_ ->
                join { room = "dabest", player = "Joba" }
                    |> ensureViewHas [ Selector.text "deck of Joba" ]
                    |> done
        , test "displays a card slot for the player" <|
            \_ ->
                join { room = "dabest", player = "Joba" }
                    |> ensureViewHas
                        [ Selector.all
                            [ Selector.class "card-slot"
                            , Selector.containing [ Selector.text "Joba" ]
                            ]
                        ]
                    |> done
        , test "a guest arriving in a room is displayed the nickname field" <|
            inRoom "dabest" <|
                \room ->
                    startAppOn room
                        |> ensureViewHasNot [ Selector.text "deck of Joba" ]
                        |> writeInField { id = "nickname", label = "Nickname", value = "Jo" }
                        |> writeInField { id = "nickname", label = "Nickname", value = "ba" }
                        |> clickButton "Join"
                        |> ensureViewHas [ Selector.text "deck of ba" ]
                        |> done
        , test "spaces are allowed in the room name" <|
            inRoom "dabest heyhey" <|
                \room ->
                    startAppOn room
                        |> expectViewHas [ Selector.text "room: dabest heyhey" ]
        ]


join : { a | room : String, player : String } -> ProgramTest (Main.Model ()) Main.Msg Effect
join { room, player } =
    startAppOn Routes.Home
        |> writeInField { id = "room", label = "Room", value = room }
        |> writeInField { id = "nickname", label = "Nickname", value = player }
        |> clickButton "Join"
