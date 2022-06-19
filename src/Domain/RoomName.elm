module Domain.RoomName exposing (RoomName, fromString, print)


type RoomName
    = RoomName String


fromString : String -> Maybe RoomName
fromString name =
    case name of
        "" ->
            Nothing

        _ ->
            Just <| RoomName name


print : RoomName -> String
print roomName =
    case roomName of
        RoomName v ->
            v
