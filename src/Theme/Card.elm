module Theme.Card exposing (..)

import Domain.Card exposing (Card)
import Element exposing (..)
import Element.Background
import Element.Border
import Element.Font
import Theme.Colors exposing (..)
import Theme.Theme exposing (noTextShadow)


front : Card -> Element msg
front label =
    Element.el
        [ width <| px 80
        , height <| px 120
        , Element.Background.color white
        , Element.Border.rounded 8
        , Theme.Theme.boxShadow
        , padding 4
        ]
    <|
        el
            [ Element.Border.rounded 8
            , Element.Border.solid
            , Element.Border.color Theme.Colors.accent
            , Element.Border.width 2
            , width fill
            , height fill
            ]
        <|
            el
                [ centerX
                , centerY
                , noTextShadow
                , Element.Font.color Theme.Colors.accent
                , Element.Font.bold
                ]
            <|
                Element.text <|
                    Domain.Card.print label


slot : Element msg
slot =
    Element.el
        [ width <| px 80
        , height <| px 120
        , Element.Border.dashed
        , Element.Border.width 2
        , Element.Border.color white
        , Element.Border.rounded 8
        ]
    <|
        Element.none
