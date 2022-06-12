module Routes exposing (..)

import Url exposing (Url)
import Url.Builder
import Url.Parser exposing ((</>), Parser, custom, map, oneOf, parse, s, top)


type Route
    = Home
    | Room String
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


roomNameParser : Parser (String -> a) a
roomNameParser =
    custom "ROOM-NAME" Url.percentDecode


toString : Route -> String
toString route =
    case route of
        Home ->
            Url.Builder.absolute [] []

        Room room ->
            Url.Builder.absolute [ "room", Url.percentEncode room ] []

        NotFound ->
            Url.Builder.absolute [ "not-found" ] []
