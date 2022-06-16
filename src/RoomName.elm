module RoomName exposing (RoomName, fromString, print)


type RoomName
    = RoomName String

fromString : String -> Maybe RoomName
fromString name =
    Maybe.Just <| RoomName name

print : RoomName -> String
print roomName =
    case roomName of
        RoomName v ->
            v
