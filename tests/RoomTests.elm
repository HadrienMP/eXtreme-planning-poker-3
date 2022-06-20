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
        [ describe "initial display" <|
            [ test "displays the room name" <|
                inRoom "dabest" <|
                    \room ->
                        startAppOn room
                            |> expectViewHas [ Selector.id "room", Selector.containing [ Selector.text "dabest" ] ]
            , test "spaces are allowed in the room name" <|
                inRoom "dabest heyhey" <|
                    \room ->
                        startAppOn room
                            |> expectViewHas
                                [ Selector.id "room"
                                , Selector.containing [ Selector.text "dabest heyhey" ]
                                ]
            , test "displays the deck of the player" <|
                \_ ->
                    join { room = "dabest", player = "Joba" }
                        |> ensureViewHas [ Selector.all [ Selector.id "my-deck", Selector.containing [ Selector.text "1" ] ] ]
                        |> ensureViewHas [ Selector.all [ Selector.id "my-deck", Selector.containing [ Selector.text "TFB" ] ] ]
                        |> ensureViewHas [ Selector.all [ Selector.id "my-deck", Selector.containing [ Selector.text "NFC" ] ] ]
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
            ]
        , describe "choosing cards"
            [ test "click a card on your deck to choose a card" <|
                \_ ->
                    join { room = "dabest", player = "Joba" }
                        |> clickButton "TFB"
                        |> clickButton "Reveal"
                        |> ensureViewHas
                            [ Selector.all
                                [ Selector.class "card-slot"
                                , Selector.containing [ Selector.text "TFB" ]
                                ]
                            ]
                        |> done
            , test "before revealing cards are hidden" <|
                \_ ->
                    join { room = "dabest", player = "Joba" }
                        |> clickButton "TFB"
                        |> ensureViewHasNot
                            [ Selector.all
                                [ Selector.class "card-slot"
                                , Selector.containing [ Selector.text "TFB" ]
                                ]
                            ]
                        |> done
            , test "click a card again to cancel the vote" <|
                \_ ->
                    join { room = "dabest", player = "Joba" }
                        |> clickButton "TFB"
                        |> clickButton "TFB"
                        |> clickButton "Reveal"
                        |> ensureViewHasNot
                            [ Selector.all
                                [ Selector.class "card-slot"
                                , Selector.containing [ Selector.text "TFB" ]
                                ]
                            ]
                        |> done
            , test "clicking a card then another changes the vote" <|
                \_ ->
                    join { room = "dabest", player = "Joba" }
                        |> clickButton "TFB"
                        |> clickButton "1"
                        |> clickButton "Reveal"
                        |> ensureViewHas
                            [ Selector.all
                                [ Selector.class "card-slot"
                                , Selector.containing [ Selector.text "1" ]
                                ]
                            ]
                        |> done
            ]
        , describe "cards revelead"
            [ test "the deck is not visible" <|
                \_ ->
                    join { room = "dabest", player = "Joba" }
                        |> clickButton "Reveal"
                        |> ensureViewHasNot [ Selector.id "my-deck" ]
                        |> done
            , test "clicking on restart resets the vote" <|
                \_ ->
                    join { room = "dabest", player = "Joba" }
                        |> clickButton "TFB"
                        |> clickButton "Reveal"
                        |> clickButton "Restart"
                        |> ensureViewHasNot
                            [ Selector.all
                                [ Selector.class "card-slot"
                                , Selector.containing [ Selector.text "TFB" ]
                                ]
                            ]
                        |> done
            , test "clicking on restart reveals the deck" <|
                \_ ->
                    join { room = "dabest", player = "Joba" }
                        |> clickButton "Reveal"
                        |> clickButton "Restart"
                        |> ensureViewHas [ Selector.text "deck of Joba" ]
                        |> done
            ]
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
        ]


join : { a | room : String, player : String } -> ProgramTest (Main.Model ()) Main.Msg Effect
join { room, player } =
    startAppOn Routes.Home
        |> writeInField { id = "room", label = "Room", value = room }
        |> writeInField { id = "nickname", label = "Nickname", value = player }
        |> clickButton "Join"
