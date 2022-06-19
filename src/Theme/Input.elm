module Theme.Input exposing (..)

import Element exposing (Element, spacingXY)
import Element.Background
import Element.Border
import Element.Font
import Element.Input
import Html.Attributes
import Theme.Colors


text : { onChange : String -> msg, value : String, label : String } -> Element msg
text { onChange, value, label } =
    Element.Input.text
        [ Element.htmlAttribute <| Html.Attributes.id <| String.toLower label
        , Element.Background.color Theme.Colors.transparent
        , Element.Font.color Theme.Colors.text
        , Element.Border.widthEach { top = 0, left = 0, right = 0, bottom = 2 }
        , Element.Border.solid
        , Element.Border.color Theme.Colors.text
        , Element.Border.rounded 0
        , Element.paddingXY 0 6
        ]
        { onChange = onChange
        , text = value
        , label = Element.Input.labelHidden label
        , placeholder = Just <| Element.Input.placeholder [ Element.Font.color Theme.Colors.text ] <| Element.text label
        }


textWithIcon : { onChange : String -> msg, value : String, label : String, icon : Element msg } -> Element msg
textWithIcon { onChange, value, label, icon } =
    Element.row
        [ Element.Border.widthEach { top = 0, left = 0, right = 0, bottom = 2 }
        , Element.Border.solid
        , Element.Border.color Theme.Colors.text
        , spacingXY 6 0
        ]
        [ Element.el [] <| icon
        , Element.Input.text
            [ Element.htmlAttribute <| Html.Attributes.id <| String.toLower label
            , Element.Background.color Theme.Colors.transparent
            , Element.Font.color Theme.Colors.text
            , Element.Border.width 0
            , Element.Border.rounded 0
            , Element.paddingXY 0 6
            ]
            { onChange = onChange
            , text = value
            , label = Element.Input.labelHidden label
            , placeholder =
                Just <|
                    Element.Input.placeholder [ Element.Font.color Theme.Colors.text ] <|
                        Element.text label
            }
        ]
