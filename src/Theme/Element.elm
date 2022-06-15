module Theme.Element exposing (..)

import Element exposing (Element)
import Routes exposing (Route)


link : { route : Route, label : String } -> Element msg
link { route, label } =
    Element.link []
        { url = Routes.toString route
        , label = Element.text label
        }
