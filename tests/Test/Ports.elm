module Test.Ports exposing (..)

import Domain.GameState as GameState exposing (GameState)
import Domain.Player as Player exposing (Player)
import Domain.Vote as Vote exposing (Vote)
import Expect
import ProgramTest exposing (..)


playerOut : String
playerOut =
    "playerOut"


ensurePlayerOut : Player -> ProgramTest model msg effect -> ProgramTest model msg effect
ensurePlayerOut =
    ensurePlayerOutTimes 1


ensurePlayerOutTimes : Int -> Player -> ProgramTest model msg effect -> ProgramTest model msg effect
ensurePlayerOutTimes times player =
    ensurePlayersOut <| List.repeat times player


ensurePlayersOut : List Player -> ProgramTest model msg effect -> ProgramTest model msg effect
ensurePlayersOut players =
    ensureOutgoingPortValues playerOut Player.decoder <|
        Expect.equal players


playersIn : String
playersIn =
    "playersIn"


playerLeft : String
playerLeft =
    "playerLeft"


votesOut : String
votesOut =
    "votesOut"


ensureVotesOut : List Vote -> ProgramTest model msg effect -> ProgramTest model msg effect
ensureVotesOut votes =
    ensureOutgoingPortValues
        votesOut
        Vote.decoder
        (Expect.equal votes)


votesIn : String
votesIn =
    "votesIn"


statesOut : String
statesOut =
    "statesOut"


statesIn : String
statesIn =
    "statesIn"


playerIdIn : String
playerIdIn =
    "playerIdIn"


ensureStatesOut : List GameState -> ProgramTest model msg effect -> ProgramTest model msg effect
ensureStatesOut states =
    ensureOutgoingPortValues
        statesOut
        GameState.decoder
        (Expect.equal states)
