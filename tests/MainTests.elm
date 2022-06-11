module MainTests exposing (..)

import ProgramTest exposing (ProgramTest, expectViewHas, expectViewHasNot, fillIn)
import Test exposing (..)
import Test.Html.Selector exposing (text)
import Main as Main


start : ProgramTest Main.Model Main.Msg (Cmd Main.Msg)
start =
    ProgramTest.createDocument
        { init = Main.init
        , update = Main.update
        , view = Main.view
        }
        |> ProgramTest.start ()


all : Test
all =
    describe "App"
        [ test "Nickname" <|
            \() ->
                start
                    |> fillIn "nickname" "Nickname" "Miss Goldman"
                    |> expectViewHas
                        [ text "Welcome Miss Goldman"
                        ]
        , test "no welcome message is displayed at the beginning" <|
            \() ->
                start
                    |> expectViewHasNot [ text "Welcome" ]
        ]
