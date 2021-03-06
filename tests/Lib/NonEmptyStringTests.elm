module Lib.NonEmptyStringTests exposing (..)

import Expect
import Lib.NonEmptyString exposing (..)
import Test exposing (..)


all : Test
all =
    describe "NonEmptyString"
        [ test "allows non empty strings" <| \_ -> create "Toto" |> Maybe.map print |> Expect.equal (Just "Toto")
        , test "rejects empty strings" <| \_ -> create "" |> Maybe.map print |> Expect.equal Nothing
        , test "rejects blank strings" <| \_ -> create "  " |> Maybe.map print |> Expect.equal Nothing
        , test "spaces around the name are deleted" <| \_ -> create " Emma " |> Maybe.map print |> Expect.equal (Just "Emma")
        ]
