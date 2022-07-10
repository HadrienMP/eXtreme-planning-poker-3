module Theme.Card exposing (action, back, front, slot)

import Element exposing (..)
import Element.Background
import Element.Border
import Element.Font
import Theme.Attributes exposing (class)
import Theme.Colors exposing (..)
import Theme.Theme exposing (noTextShadow)


back : Element msg
back =
    Element.el
        [ width <| px 80
        , height <| px 120
        , Element.Background.color white
        , Element.Border.rounded 8
        , Theme.Theme.boxShadow
        , padding 4
        , class "card-back"
        ]
    <|
        el
            [ Element.Border.rounded 8
            , Element.Border.solid
            , Element.Border.color Theme.Colors.accent
            , Element.Border.width 2
            , width fill
            , height fill
            , Theme.Theme.stripes ( white, accent )
            ]
        <|
            none


front : { label : String } -> Element msg
front { label } =
    front_ { label = label, size = Regular }


action : { label : String } -> Element msg
action { label } =
    front_ { label = label, size = Small }


type ActionSize
    = Regular
    | Small


front_ : { label : String, size : ActionSize } -> Element msg
front_ { label, size } =
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
                , case size of
                    Regular ->
                        Element.Font.size 20

                    Small ->
                        Element.Font.size 14
                ]
            <|
                Element.text label


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
