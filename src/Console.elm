port module Console exposing (..)


port log : String -> Cmd msg


port error : String -> Cmd msg


port warn : String -> Cmd msg
