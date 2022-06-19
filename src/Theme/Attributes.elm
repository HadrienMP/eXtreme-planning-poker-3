module Theme.Attributes exposing (..)

import Element
import Html.Attributes


id : String -> Element.Attribute msg
id =
    Element.htmlAttribute << Html.Attributes.id
