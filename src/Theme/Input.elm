module Theme.Input exposing (text, textWithIcon)

import Element exposing (Element, paddingEach, spacingXY)
import Element.Background
import Element.Border
import Element.Font
import Element.Input
import Html.Attributes
import Theme.Colors
import Theme.Theme exposing (emptySides)


text : { onChange : String -> msg, value : String, label : String } -> Element msg
text { onChange, value, label } =
    Element.el [] <|
        text_ { onChange = onChange, value = value, label = label }


textWithIcon : { onChange : String -> msg, value : String, label : String, icon : Element msg } -> Element msg
textWithIcon { onChange, value, label, icon } =
    Element.row
        [ Element.Border.widthEach { emptySides | bottom = 2 }
        , Element.Border.solid
        , Element.Border.color Theme.Colors.text
        , spacingXY 10 0
        , paddingEach { emptySides | bottom = 4 }
        ]
        [ Element.el [] <| icon
        , text_ { onChange = onChange, value = value, label = label }
        ]


text_ : { onChange : String -> msg, value : String, label : String } -> Element msg
text_ { onChange, value, label } =
    Element.Input.text
        [ Element.htmlAttribute <| Html.Attributes.id <| String.toLower label
        , Element.Background.color Theme.Colors.transparent
        , Element.Font.color Theme.Colors.text
        , Element.Border.width 0
        , Element.Border.rounded 0
        , Element.paddingXY 0 6
        , Theme.Theme.textShadow
        ]
        { onChange = onChange
        , text = value
        , label = Element.Input.labelHidden label
        , placeholder = Just <| Element.Input.placeholder [ Element.Font.color Theme.Colors.text ] <| Element.text label
        }
