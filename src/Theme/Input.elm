module Theme.Input exposing (..)

import Element exposing (Element)
import Element.Input
import Html.Attributes


text : { onChange : String -> msg, value : String, label : String } -> Element msg
text { onChange, value, label } =
    Element.Input.text [ Element.htmlAttribute <| Html.Attributes.id <| String.toLower label ]
        { onChange = onChange
        , text = value
        , label = Element.Input.labelHidden label
        , placeholder = Just <| Element.Input.placeholder [] <| Element.text label
        }
