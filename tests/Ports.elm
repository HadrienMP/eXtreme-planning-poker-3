module Ports exposing (..)

import Domain.GameState as GameState exposing (GameState)
import Domain.Player as Player exposing (Player)
import Domain.Vote as Vote exposing (Vote)
import Expect
import ProgramTest exposing (..)


playerOut : String
playerOut =
    "player"


ensurePlayerOut : Player -> ProgramTest model msg effect -> ProgramTest model msg effect
ensurePlayerOut player =
    ensureOutgoingPortValues
        playerOut
        Player.decoder
        (Expect.equal [ player ])


playersIn : String
playersIn =
    "playersIn"


votesOut : String
votesOut =
    "votes"


ensureVotesOut : List Vote -> ProgramTest model msg effect -> ProgramTest model msg effect
ensureVotesOut votes =
    ensureOutgoingPortValues
        votesOut
        Vote.decoder
        (Expect.equal votes)


statesOut : String
statesOut =
    "states"


ensureStatesOut : List GameState -> ProgramTest model msg effect -> ProgramTest model msg effect
ensureStatesOut states =
    ensureOutgoingPortValues
        statesOut
        GameState.decoder
        (Expect.equal states)
