module Routes exposing (..)

import RoomName
import Url exposing (Url)
import Url.Builder
import Url.Parser exposing ((</>), Parser, custom, map, oneOf, parse, s, top)


type Route
    = Home
    | Room RoomName.RoomName
    | NotFound


parseRoute : Url -> Route
parseRoute url =
    case parse routeParser url of
        Nothing ->
            NotFound

        Just route ->
            route


routeParser : Parser (Route -> a) a
routeParser =
    oneOf
        [ map Home top
        , map Room (s "room" </> roomNameParser)
        ]


roomNameParser : Parser (RoomName.RoomName -> a) a
roomNameParser =
    custom "ROOM-NAME" (Url.percentDecode >> Maybe.andThen RoomName.fromString)


toString : Route -> String
toString route =
    case route of
        Home ->
            Url.Builder.absolute [] []

        Room room ->
            Url.Builder.absolute [ "room", room |> RoomName.print |> Url.percentEncode ] []

        NotFound ->
            Url.Builder.absolute [ "not-found" ] []
