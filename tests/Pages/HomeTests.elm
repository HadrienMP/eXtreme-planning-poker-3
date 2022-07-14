module Pages.HomeTests exposing (..)

import Expect
import Html.Attributes as Attr
import ProgramTest exposing (..)
import Routes
import Test exposing (..)
import Test.Html.Query as Query
import Test.Html.Selector as Selector
import Test.TestSetup exposing (..)


all : Test
all =
    describe "Home"
        [ test "Clicking on join redirects you to the room you chose" <|
            \_ ->
                startAppOn Routes.Home
                    |> withAPlayerId
                    |> writeInField { id = "room", label = "Room", value = "dabest" }
                    |> writeInField { id = "nickname", label = "Nickname", value = "Joba" }
                    |> clickButton "Join"
                    |> expectBrowserUrl (Expect.equal <| baseUrl ++ "/room/dabest")
        , test "Room names can't be empty" <|
            \_ ->
                startAppOn Routes.Home
                    |> withAPlayerId
                    |> writeInField { id = "room", label = "Room", value = "" }
                    |> writeInField { id = "nickname", label = "Nickname", value = "Joba" }
                    |> ensureView
                        (Query.find
                            [ Selector.attribute <| Attr.attribute "role" "button"
                            , Selector.containing [ Selector.text "Join" ]
                            ]
                            >> Query.has [ Selector.attribute <| Attr.disabled True ]
                        )
                    |> done
        ]
