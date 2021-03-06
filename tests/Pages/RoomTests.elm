module Pages.RoomTests exposing (..)

import Domain.Card as Card
import Domain.GameState as GameState
import Domain.Nickname as Nickname
import Domain.Player as Player exposing (Player)
import Domain.PlayerId as PlayerId exposing (PlayerId)
import Domain.RoomName as Room
import Domain.Vote as Vote
import Effect exposing (Effect)
import Main
import ProgramTest exposing (..)
import Routes
import Test exposing (..)
import Test.Fixtures exposing (emma, pierre, playerNamed)
import Test.Html.Selector as Selector
import Test.Ports exposing (ensurePlayerOut, ensurePlayerOutTimes, ensurePlayersOut, ensureStatesOut, ensureVotesOut)
import Test.TestSetup exposing (..)
import Test.Utils exposing (..)


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
        withMaybe3 ( Room.fromString "dabest", PlayerId.create "ba-id", Nickname.create "ba" ) <|
            \( room, id, nickname ) ->
                startAppOn (Routes.Room room)
                    |> withPlayerId id
                    |> ensureViewHasNot [ Selector.text "deck of Joba" ]
                    |> writeInField { id = "nickname", label = "Nickname", value = "Jo" }
                    |> writeInField { id = "nickname", label = "Nickname", value = Nickname.print nickname }
                    |> clickButton "Join"
                    |> ensureViewHas [ Selector.all [ Selector.id "my-deck", Selector.containing [ Selector.text <| Nickname.print nickname ] ] ]
                    |> ensurePlayerOut (Player.Player id nickname)
                    |> done
    , test "share the player's identity when they initialize the room also" <|
        withMaybe pierre <|
            \pierre ->
                join { room = "dabest", player = pierre }
                    |> ensurePlayerOut pierre
                    |> done
    , describe "connection/disconnection"
        [ describe "loader"
            [ describe "When setting up"
                [ test "display a loader when the player id is not defined" <|
                    inRoom "dabest" <|
                        \room ->
                            startAppOn room
                                |> ensureViewHas [ Selector.id "loader" ]
                                |> done
                , test "display a loader when got disconnected" <|
                    inRoom "dabest" <|
                        \room ->
                            startAppOn room
                                |> withAPlayerId
                                |> gotDisconnected
                                |> ensureViewHas [ Selector.id "loader" ]
                                |> done
                , test "loader disappears when connection comes back" <|
                    inRoom "dabest" <|
                        \room ->
                            startAppOn room
                                |> withAPlayerId
                                |> gotDisconnected
                                |> withAPlayerId
                                |> ensureViewHasNot [ Selector.id "loader" ]
                                |> done
                ]
            , describe "When Ready"
                [ test "display a loader when got disconnected" <|
                    withMaybe pierre <|
                        \pierre ->
                            join { room = "dabest", player = pierre }
                                |> gotDisconnected
                                |> ensureViewHas [ Selector.id "loader" ]
                                |> done
                , test "loader disappears when connection comes back" <|
                    withMaybe pierre <|
                        \pierre ->
                            join { room = "dabest", player = pierre }
                                |> gotDisconnected
                                |> withAPlayerId
                                |> ensureViewHasNot [ Selector.id "loader" ]
                                |> done
                ]
            ]
        , describe "playerOut"
            [ test "send the player data out after getting an id again -  to handle network disconnect and reconnect" <|
                withMaybe pierre <|
                    \pierre ->
                        join { room = "dabest", player = pierre }
                            |> withPlayerId pierre.id
                            |> ensurePlayerOutTimes 2 pierre
                            |> done
            , test "playerIds change after disconnections" <|
                withMaybe2 ( PlayerId.create "another-id", playerNamed "Pierre" ) <|
                    \( anotherId, pierre ) ->
                        join { room = "dabest", player = pierre }
                            |> withPlayerId anotherId
                            |> ensurePlayersOut [ pierre, { pierre | id = anotherId } ]
                            |> done
            ]
        ]
    ]


cardsRevealed : List Test
cardsRevealed =
    [ test "the deck is not visible" <|
        withMaybe pierre <|
            \pierre ->
                join { room = "dabest", player = pierre }
                    |> clickButton "Reveal"
                    |> ensureViewHasNot [ Selector.id "my-deck" ]
                    |> done
    , test "clicking on restart resets the vote" <|
        withMaybe pierre <|
            \pierre ->
                join { room = "dabest", player = pierre }
                    |> clickButton "TFB"
                    |> clickButton "Reveal"
                    |> clickButton "Restart"
                    |> ensureViewHasNot
                        [ Selector.all
                            [ Selector.class "card-slot"
                            , Selector.containing [ Selector.all [ Selector.text "TFB", Selector.text <| Nickname.print pierre.nickname ] ]
                            ]
                        ]
                    |> ensureStatesOut [ GameState.Chosen, GameState.Choosing ]
                    |> done
    , test "clicking on restart reveals the deck" <|
        withMaybe pierre <|
            \pierre ->
                join { room = "dabest", player = pierre }
                    |> clickButton "Reveal"
                    |> clickButton "Restart"
                    |> ensureViewHas [ Selector.all [ Selector.id "my-deck", Selector.containing [ Selector.text <| Nickname.print pierre.nickname ] ] ]
                    |> done
    ]


choosingCards : List Test
choosingCards =
    [ myActions
    , peerActions
    ]


myActions : Test
myActions =
    describe "my actions"
        [ test "arriving in room - click a card on your deck to choose a card" <|
            withMaybe2 ( Room.fromString "dabest", PlayerId.create "playerId-joba" ) <|
                \( room, playerId ) ->
                    startAppOn (Routes.Room room)
                        |> withPlayerId playerId
                        |> writeInField { id = "nickname", label = "Nickname", value = "Joba" }
                        |> clickButton "Join"
                        |> clickButton "TFB"
                        |> ensureCardIsSelected "TFB"
                        |> clickButton "Reveal"
                        |> ensureViewHas
                            [ Selector.class "card-slot"
                            , Selector.containing [ Selector.text "TFB" ]
                            ]
                        |> ensureVotesOut [ Vote.Vote playerId (Just <| Card.fromString "TFB") ]
                        |> done
        , test "creating the room - click a card on your deck to choose a card" <|
            withMaybe (PlayerId.create "playerId-joba") <|
                \playerId ->
                    joinWithPlayerId { room = "dabest", player = { nickname = "Joba", id = playerId } }
                        |> clickButton "TFB"
                        |> ensureCardIsSelected "TFB"
                        |> clickButton "Reveal"
                        |> ensureViewHas
                            [ Selector.class "card-slot"
                            , Selector.containing [ Selector.text "TFB" ]
                            ]
                        |> ensureVotesOut [ Vote.Vote playerId (Just <| Card.fromString "TFB") ]
                        |> done
        , test "before revealing cards are hidden" <|
            withMaybe pierre <|
                \pierre ->
                    join { room = "dabest", player = pierre }
                        |> clickButton "TFB"
                        |> ensureViewHasNot
                            [ Selector.all
                                [ Selector.class "card-slot"
                                , Selector.containing [ Selector.text "TFB" ]
                                ]
                            ]
                        |> done
        , test "click a card again to cancel the vote" <|
            withMaybe (PlayerId.create "playerId-joba") <|
                \playerId ->
                    joinWithPlayerId { room = "dabest", player = { nickname = "Joba", id = playerId } }
                        |> clickButton "TFB"
                        |> clickButton "TFB"
                        |> clickButton "Reveal"
                        |> ensureViewHasNot
                            [ Selector.all
                                [ Selector.class "card-slot"
                                , Selector.containing [ Selector.text "TFB" ]
                                ]
                            ]
                        |> ensureVotesOut
                            [ Vote.Vote playerId (Just <| Card.fromString "TFB")
                            , Vote.Vote playerId Nothing
                            ]
                        |> done
        , test "clicking a card then another changes the vote" <|
            withMaybe pierre <|
                \pierre ->
                    join { room = "dabest", player = pierre }
                        |> clickButton "TFB"
                        |> clickButton "1"
                        |> clickButton "Reveal"
                        |> ensureViewHas
                            [ Selector.class "card-slot"
                            , Selector.containing [ Selector.text "1" ]
                            ]
                        |> done
        , test "clicking Reveal reveals the votes" <|
            withMaybe pierre <|
                \pierre ->
                    join { room = "dabest", player = pierre }
                        |> clickButton "TFB"
                        |> clickButton "Reveal"
                        |> ensureViewHas
                            [ Selector.class "card-slot"
                            , Selector.containing [ Selector.text "TFB" ]
                            ]
                        |> ensureStatesOut [ GameState.Chosen ]
                        |> done
        ]


peerActions : Test
peerActions =
    describe "peer actions"
        [ test "Emma joined" <|
            withMaybe2 ( pierre, emma ) <|
                \( pierre, emma ) ->
                    join { room = "dabest", player = pierre }
                        |> simulateIncomingPort Test.Ports.playersIn (Player.json emma)
                        |> ensureViewHas
                            [ Selector.class "card-slot"
                            , Selector.containing [ Selector.text <| Nickname.print <| emma.nickname ]
                            ]
                        |> done
        , test "Emma voted" <|
            withMaybe2 ( pierre, emma ) <|
                \( pierre, emma ) ->
                    join { room = "dabest", player = pierre }
                        |> simulateIncomingPort Test.Ports.playersIn (Player.json emma)
                        |> simulateIncomingPort Test.Ports.votesIn (Vote.json (Vote.Vote emma.id <| Just <| Card.fromString "TFB"))
                        |> clickButton "Reveal"
                        |> ensureViewHas
                            [ Selector.class "card-slot"
                            , Selector.containing [ Selector.text "TFB" ]
                            ]
                        |> done
        , test "Emma revealed the cards" <|
            withMaybe2 ( pierre, emma ) <|
                \( pierre, emma ) ->
                    join { room = "dabest", player = pierre }
                        |> simulateIncomingPort Test.Ports.playersIn (Player.json emma)
                        |> simulateIncomingPort Test.Ports.votesIn (Vote.json (Vote.Vote emma.id <| Just <| Card.fromString "TFB"))
                        |> simulateIncomingPort Test.Ports.statesIn (GameState.json GameState.Chosen)
                        |> ensureViewHas
                            [ Selector.class "card-slot"
                            , Selector.containing [ Selector.text "TFB" ]
                            ]
                        |> done
        , test "Emma restarted the game, the votes are reset" <|
            withMaybe2 ( pierre, emma ) <|
                \( pierre, emma ) ->
                    join { room = "dabest", player = pierre }
                        |> clickButton "1"
                        |> simulateIncomingPort Test.Ports.playersIn (Player.json emma)
                        |> simulateIncomingPort Test.Ports.votesIn (Vote.json (Vote.Vote emma.id <| Just <| Card.fromString "TFB"))
                        |> simulateIncomingPort Test.Ports.statesIn (GameState.json GameState.Chosen)
                        |> simulateIncomingPort Test.Ports.statesIn (GameState.json GameState.Choosing)
                        |> ensureNoCardIsSelected
                        |> done
        , test "Emma left" <|
            withMaybe2 ( pierre, emma ) <|
                \( pierre, emma ) ->
                    join { room = "dabest", player = pierre }
                        |> simulateIncomingPort Test.Ports.playersIn (Player.json emma)
                        |> simulateIncomingPort Test.Ports.playerLeft (PlayerId.json emma.id)
                        |> ensureViewHasNot
                            [ Selector.all
                                [ Selector.class "card-slot"
                                , Selector.containing [ Selector.text <| Nickname.print emma.nickname ]
                                ]
                            ]
                        |> done
        , test "Messages saying that you left are ignored - we never want you to disappear" <|
            withMaybe pierre <|
                \pierre ->
                    join { room = "dabest", player = pierre }
                        |> ensureViewHas
                            [ Selector.class "card-slot"
                            , Selector.containing [ Selector.text <| Nickname.print pierre.nickname ]
                            ]
                        |> simulateIncomingPort Test.Ports.playerLeft (PlayerId.json pierre.id)
                        |> ensureViewHas
                            [ Selector.all
                                [ Selector.class "card-slot"
                                , Selector.containing [ Selector.text <| Nickname.print pierre.nickname ]
                                ]
                            ]
                        |> done
        , test "emma left then joined again" <|
            withMaybe2 ( pierre, emma ) <|
                \( pierre, emma ) ->
                    join { room = "dabest", player = pierre }
                        |> simulateIncomingPort Test.Ports.playersIn (Player.json emma)
                        |> simulateIncomingPort Test.Ports.playerLeft (PlayerId.json emma.id)
                        |> simulateIncomingPort Test.Ports.playersIn (Player.json emma)
                        |> ensureViewHas
                            [ Selector.class "card-slot"
                            , Selector.containing [ Selector.text <| Nickname.print emma.nickname ]
                            ]
                        |> done
        ]


ensureCardIsSelected : String -> ProgramTest (Main.Model ()) Main.Msg Effect -> ProgramTest (Main.Model ()) Main.Msg Effect
ensureCardIsSelected card =
    ensureViewHas
        [ Selector.class "card-back"
        , Selector.all
            [ Selector.id "my-deck"
            , Selector.containing
                [ Selector.class "selected"
                , Selector.containing [ Selector.text card ]
                ]
            ]
        ]


ensureNoCardIsSelected : ProgramTest (Main.Model ()) Main.Msg Effect -> ProgramTest (Main.Model ()) Main.Msg Effect
ensureNoCardIsSelected =
    ensureViewHasNot [ Selector.class "card-back" ]
        >> ensureViewHasNot
            [ Selector.all
                [ Selector.id "my-deck"
                , Selector.containing [ Selector.class "selected" ]
                ]
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
        withMaybe pierre <|
            \pierre ->
                join { room = "dabest", player = pierre }
                    |> ensureViewHas [ Selector.all [ Selector.id "my-deck", Selector.containing [ Selector.text "1" ] ] ]
                    |> ensureViewHas [ Selector.all [ Selector.id "my-deck", Selector.containing [ Selector.text "TFB" ] ] ]
                    |> ensureViewHas [ Selector.all [ Selector.id "my-deck", Selector.containing [ Selector.text "NFC" ] ] ]
                    |> ensureViewHas [ Selector.all [ Selector.id "my-deck", Selector.containing [ Selector.text <| Nickname.print pierre.nickname ] ] ]
                    |> done
    , test "displays a card slot for the player" <|
        withMaybe pierre <|
            \pierre ->
                join { room = "dabest", player = pierre }
                    |> ensureViewHas
                        [ Selector.class "card-slot"
                        , Selector.containing [ Selector.text <| Nickname.print pierre.nickname ]
                        ]
                    |> done
    ]


join : { a | room : String, player : Player } -> ProgramTest (Main.Model ()) Main.Msg Effect
join { room, player } =
    startAppOn Routes.Home
        |> withPlayerId player.id
        |> writeInField { id = "room", label = "Room", value = room }
        |> writeInField { id = "nickname", label = "Nickname", value = Nickname.print player.nickname }
        |> clickButton "Join"


joinWithPlayerId : { a | room : String, player : { nickname : String, id : PlayerId } } -> ProgramTest (Main.Model ()) Main.Msg Effect
joinWithPlayerId { room, player } =
    startAppOn Routes.Home
        |> withPlayerId player.id
        |> writeInField { id = "room", label = "Room", value = room }
        |> writeInField { id = "nickname", label = "Nickname", value = player.nickname }
        |> clickButton "Join"
