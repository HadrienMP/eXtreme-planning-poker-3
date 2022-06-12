module Routes exposing (..)

import Url exposing (Url)
import Url.Parser exposing ((</>), Parser, map, oneOf, parse, s, string, top)


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
        , map Room (s "room" </> string)
        ]


toString : Route -> String
toString route =
    case route of
        Home ->
            "/"

        Room room ->
            "/room/" ++ room

        NotFound ->
            "/not-found"
