module Theme.Attributes exposing (..)

import Element
import Html.Attributes


id : String -> Element.Attribute msg
id =
    Element.htmlAttribute << Html.Attributes.id
class : String -> Element.Attribute msg
class =
    Element.htmlAttribute << Html.Attributes.class
