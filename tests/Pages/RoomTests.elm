module Pages.RoomTests exposing (..)

import Effect exposing (Effect)
import Expect
import FeatherIcons exposing (play)
import Lib.NonEmptyString as NES exposing (NonEmptyString)
import Main
import Pages.Room exposing (Msg(..))
import ProgramTest exposing (..)
import Routes
import Test exposing (..)
import Test.Html.Selector as Selector
import TestSetup exposing (..)
import Utils exposing (..)
import IO.VoteIO as VoteIO exposing (VoteIO)
import Domain.Card as Card


all : Test
all =
    describe "Room"
        [ describe "initial display" initialDisplay
        , describe "choosing cards" choosingCards
        , describe "cards revelead" cardsRevealed
        , describe "setup" setup
        ]


setup : List Test
setup =
    [ test "a guest arriving in a room is displayed the nickname field" <|
        inRoom "dabest" <|
            \room ->
                startAppOn room
                    |> withAPlayerId
                    |> ensureViewHasNot [ Selector.text "deck of Joba" ]
                    |> writeInField { id = "nickname", label = "Nickname", value = "Jo" }
                    |> writeInField { id = "nickname", label = "Nickname", value = "ba" }
                    |> clickButton "Join"
                    |> ensureViewHas [ Selector.all [ Selector.id "my-deck", Selector.containing [ Selector.text "ba" ] ] ]
                    |> done
    , test "display a loader when the player id is not defined" <|
        inRoom "dabest" <|
            \room ->
                startAppOn room
                    |> ensureViewHas [ Selector.id "loader" ]
                    |> done
    ]


cardsRevealed : List Test
cardsRevealed =
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
                        , Selector.containing [ Selector.all [ Selector.text "TFB", Selector.text "Jojo" ] ]
                        ]
                    ]
                |> done
    , test "clicking on restart reveals the deck" <|
        \_ ->
            join { room = "dabest", player = "Joba" }
                |> clickButton "Reveal"
                |> clickButton "Restart"
                |> ensureViewHas [ Selector.all [ Selector.id "my-deck", Selector.containing [ Selector.text "Joba" ] ] ]
                |> done
    ]


choosingCards : List Test
choosingCards =
    [ test "click a card on your deck to choose a card" <|
        withMaybe (NES.create "playerId-joba") <|
            \playerId ->
                join { room = "dabest", player = "Joba" }
                    |> withPlayerId playerId
                    |> clickButton "TFB"
                    |> clickButton "Reveal"
                    |> ensureViewHas
                        [ Selector.all
                            [ Selector.class "card-slot"
                            , Selector.containing [ Selector.text "TFB" ]
                            ]
                        ]
                    |> ensureOutgoingPortValues
                        "vote"
                        VoteIO.decoder
                        (Expect.equal [ VoteIO playerId (Card.fromString "TFB") ])
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


initialDisplay : List Test
initialDisplay =
    [ test "displays the room name" <|
        inRoom "dabest" <|
            \room ->
                startAppOn room
                    |> withAPlayerId
                    |> expectViewHas [ Selector.id "room", Selector.containing [ Selector.text "dabest" ] ]
    , test "spaces are allowed in the room name" <|
        inRoom "dabest heyhey" <|
            \room ->
                startAppOn room
                    |> withAPlayerId
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
                |> ensureViewHas [ Selector.all [ Selector.id "my-deck", Selector.containing [ Selector.text "Joba" ] ] ]
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


join : { a | room : String, player : String } -> ProgramTest (Main.Model ()) Main.Msg Effect
join { room, player } =
    startAppOn Routes.Home
        |> withAPlayerId
        |> writeInField { id = "room", label = "Room", value = room }
        |> writeInField { id = "nickname", label = "Nickname", value = player }
        |> clickButton "Join"
