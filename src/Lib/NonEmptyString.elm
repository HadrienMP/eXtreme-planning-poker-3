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


print : NonEmptyString -> String
print nonEmptyString =
    case nonEmptyString of
        NonEmptyString value ->
            value
