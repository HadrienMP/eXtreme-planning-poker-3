module Theme.Input exposing (buttonWithIcon, textWithIcon)

import Element as E exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html.Attributes
import Theme.Colors
import Theme.Theme exposing (emptySides, noTextShadow)


textWithIcon : { onChange : String -> msg, value : String, label : String, icon : Element msg } -> Element msg
textWithIcon { onChange, value, label, icon } =
    row
        [ Border.widthEach { emptySides | bottom = 2 }
        , Border.solid
        , Border.color Theme.Colors.text
        , spacing 10
        , paddingEach { emptySides | bottom = 8 }
        , width fill
        ]
        [ icon
        , text_ { onChange = onChange, value = value, label = label }
        ]


text_ : { onChange : String -> msg, value : String, label : String } -> Element msg
text_ { onChange, value, label } =
    Input.text
        [ htmlAttribute <| Html.Attributes.id <| String.toLower label
        , Background.color Theme.Colors.transparent
        , Font.color Theme.Colors.text
        , Border.width 0
        , Border.rounded 0
        , padding 0
        , width fill
        ]
        { onChange = onChange
        , text = value
        , label = Input.labelHidden label
        , placeholder = Just <| Input.placeholder [ Font.color Theme.Colors.placeholder, noTextShadow ] <| E.text label
        }


buttonWithIcon : { onPress : Maybe msg, icon : Element msg, label : String } -> Element msg
buttonWithIcon data =
    Input.button
        [ Background.color Theme.Colors.white
        , paddingXY 20 10
        , centerX
        , Border.rounded 100
        , Font.color Theme.Colors.accent
        , noTextShadow
        , width fill
        ]
        { onPress = data.onPress
        , label =
            row [ spacingXY 6 0, centerX ]
                [ data.icon
                , E.text data.label
                ]
        }
