module Lib.NonEmptyString exposing (..)

import String exposing (trim)


type NonEmptyString
    = NonEmptyString String


create : String -> Maybe NonEmptyString
create value =
    trim value
        |> (\trimmed ->
                if trimmed == "" then
                    Nothing

                else
                    Just <| NonEmptyString trimmed
           )


asString : NonEmptyString -> String
asString nonEmptyString =
    case nonEmptyString of
        NonEmptyString value ->
            value
