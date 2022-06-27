module Lib.NonEmptyString exposing (..)

import Json.Decode
import Json.Encode
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


json : NonEmptyString -> Json.Encode.Value
json =
    print
        >> Json.Encode.string


decoder : Json.Decode.Decoder NonEmptyString
decoder =
    Json.Decode.string
        |> Json.Decode.map create
        |> Json.Decode.andThen
            (\it ->
                case it of
                    Just a ->
                        Json.Decode.succeed a

                    Nothing ->
                        Json.Decode.fail "NonEmptyString cannot be empty"
            )
