module Theme.Theme exposing (..)

import Element exposing (Color, Element, clip, el, fill, rgba)
import Element.Background
import Element.Border
import Element.Font
import FeatherIcons exposing (Icon)
import Html exposing (Html)
import Html.Attributes
import String exposing (concat)
import Theme.Colors exposing (hexToRgba, moreTransparent)


pageBackground : List (Element.Attribute msg)
pageBackground =
    [ Element.Background.color <| hexToRgba "#08AEEA"
    , Element.htmlAttribute <|
        Html.Attributes.style "background-image" "linear-gradient(0deg, #08AEEA 0%, #2AF598 100%)"
    ]


stripes : ( Color, Color ) -> Element.Attribute msg
stripes ( first, second ) =
    concat
        [ "repeating-linear-gradient( 45deg, "
        , toRgbaString first
        , ", "
        , toRgbaString first
        , " 10px, "
        , toRgbaString second
        , " 10px, "
        , toRgbaString second
        , " 20px )"
        ]
        |> Html.Attributes.style "background"
        |> Element.htmlAttribute


toRgbaString : Color -> String
toRgbaString first =
    Element.toRgb first
        |> (\{ red, green, blue, alpha } -> [ red, green, blue, alpha ])
        |> (\parts ->
                parts
                    |> List.map ((*) 255)
                    |> List.map floor
                    |> List.map String.fromInt
                    |> String.join ", "
                    |> (\it -> concat [ "rgba(", it, ")" ])
           )


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
    Element.Font.shadow
        { offset = ( 1, 1 )
        , blur = 1
        , color = Theme.Colors.black
        }


boxShadow : Element.Attribute msg
boxShadow =
    Element.Border.shadow
        { offset = ( 1, 1 )
        , size = 1
        , blur = 1
        , color = Theme.Colors.black |> moreTransparent 7
        }


emptySides : { top : Int, left : Int, right : Int, bottom : Int }
emptySides =
    { top = 0, left = 0, right = 0, bottom = 0 }


featherIconToElement : { shadow : Bool } -> Icon -> Element msg
featherIconToElement { shadow } icon =
    icon
        |> FeatherIcons.toHtml
            [ if shadow then
                Html.Attributes.style "filter" "drop-shadow(1px 1px 1px rgb(0 0 0 / 1))"

              else
                Html.Attributes.style "" ""
            ]
        |> Element.html
        |> Element.el []


ellipsisText : List (Element.Attribute msg) -> String -> Element msg
ellipsisText attributes label =
    el (attributes ++ [ Element.width fill ]) <|
        Element.html <|
            Html.p
                [ Html.Attributes.style "text-overflow" "ellipsis"
                , Html.Attributes.style "overflow" "hidden"
                , Html.Attributes.style "max-width" "100%"
                , Html.Attributes.title label
                , Html.Attributes.style "margin" "0"
                ]
                [ Html.text label ]
