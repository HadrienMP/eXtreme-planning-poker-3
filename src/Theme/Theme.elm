module Theme.Theme exposing (..)

import Element exposing (rgba)
import Element.Background
import Element.Font
import Html exposing (Html)
import Html.Attributes
import Theme.Colors exposing (hexToRgba)


pageBackground : List (Element.Attribute msg)
pageBackground =
    [ Element.Background.color <| hexToRgba "#08AEEA"
    , Element.htmlAttribute <|
        Html.Attributes.style "background-image" "linear-gradient(0deg, #08AEEA 0%, #2AF598 100%)"
    ]


noTextShadow : Element.Attribute msg
noTextShadow =
    Element.Font.shadow
        { offset = ( 0, 0 )
        , blur = 0
        , color = rgba 0 0 0 0
        }


layout : Element.Element msg -> Html msg
layout =
    Element.layoutWith
        { options =
            [ Element.focusStyle
                { borderColor = Nothing
                , backgroundColor = Nothing
                , shadow = Nothing
                }
            ]
        }
        (pageBackground
            ++ [ Element.Font.color Theme.Colors.text
               , textShadow
               ]
        )
        << Element.el
            [ Element.centerX
            , Element.centerY
            ]


textShadow : Element.Attribute msg
textShadow =
    Element.Font.shadow { offset = ( 1, 1 ), blur = 1, color = Theme.Colors.black }


emptySides : { top : Int, left : Int, right : Int, bottom : Int }
emptySides =
    { top = 0, left = 0, right = 0, bottom = 0 }
