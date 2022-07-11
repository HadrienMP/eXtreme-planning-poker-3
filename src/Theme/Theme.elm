module Theme.Theme exposing (..)

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import FeatherIcons exposing (Icon)
import Html exposing (Html)
import Html.Attributes
import String exposing (concat)
import Theme.Colors exposing (hexToRgba, moreTransparent, white)


pageBackground : List (Attribute msg)
pageBackground =
    [ Background.color <| hexToRgba "#08AEEA"
    , htmlAttribute <|
        Html.Attributes.style "background-image" "linear-gradient(0deg, #08AEEA 0%, #2AF598 100%)"
    ]


stripes : ( Color, Color ) -> Attribute msg
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
        |> htmlAttribute


toRgbaString : Color -> String
toRgbaString first =
    toRgb first
        |> (\{ red, green, blue, alpha } -> [ red, green, blue, alpha ])
        |> (\parts ->
                parts
                    |> List.map ((*) 255)
                    |> List.map floor
                    |> List.map String.fromInt
                    |> String.join ", "
                    |> (\it -> concat [ "rgba(", it, ")" ])
           )


noTextShadow : Attribute msg
noTextShadow =
    Font.shadow
        { offset = ( 0, 0 )
        , blur = 0
        , color = rgba 0 0 0 0
        }


layout : Element msg -> Html msg
layout =
    layoutWith
        { options =
            [ focusStyle
                { borderColor = Nothing
                , backgroundColor = Nothing
                , shadow = Nothing
                }
            ]
        }
        (pageBackground
            ++ [ Font.color Theme.Colors.text
               , textShadow
               ]
        )
        << el
            [ centerX
            , centerY
            , pageWidth
            ]


textShadow : Attribute msg
textShadow =
    Font.shadow
        { offset = ( 1, 1 )
        , blur = 1
        , color = Theme.Colors.black
        }


boxShadow : Attribute msg
boxShadow =
    Border.shadow
        { offset = ( 1, 2 )
        , size = 2
        , blur = 2
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
        |> html
        |> el []


ellipsisText : List (Attribute msg) -> String -> Element msg
ellipsisText attributes label =
    el (attributes ++ [ width fill ]) <|
        html <|
            Html.p
                [ Html.Attributes.style "text-overflow" "ellipsis"
                , Html.Attributes.style "overflow" "hidden"
                , Html.Attributes.style "max-width" "100%"
                , Html.Attributes.title label
                , Html.Attributes.style "margin" "0"
                ]
                [ Html.text label ]


pageWidth : Attribute msg
pageWidth =
    shrink |> maximum 270 |> width


bottomBorder : List (Attribute msg)
bottomBorder =
    [ paddingEach { emptySides | bottom = 10 }
    , Border.widthEach { emptySides | bottom = 2 }
    , Border.color white
    ]
