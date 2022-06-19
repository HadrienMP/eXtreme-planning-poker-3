module Routes exposing (..)

import Domain.RoomName exposing (RoomName)
import Url exposing (Url)
import Url.Builder
import Url.Parser exposing ((</>), Parser, custom, map, oneOf, parse, s, top)


type Route
    = Home
    | Room RoomName
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


roomNameParser : Parser (RoomName -> a) a
roomNameParser =
    custom "ROOM-NAME" (Url.percentDecode >> Maybe.andThen Domain.RoomName.fromString)


toString : Route -> String
toString route =
    case route of
        Home ->
            Url.Builder.absolute [] []

        Room room ->
            Url.Builder.absolute [ "room", room |> Domain.RoomName.print |> Url.percentEncode ] []

        NotFound ->
            Url.Builder.absolute [ "not-found" ] []
