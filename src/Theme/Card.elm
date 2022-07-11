module Theme.Card exposing (action, back, front, slot)

import Element exposing (..)
import Element.Background
import Element.Border
import Element.Font exposing (center)
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


front : { label : String, icon : Element msg } -> Element msg
front { label, icon } =
    front_ { label = label, type_ = Regular, icon = icon }


action : { label : String, icon : Element msg } -> Element msg
action { label, icon } =
    front_ { label = label, type_ = Action, icon = icon }


type CardType
    = Action
    | Regular


front_ : { label : String, type_ : CardType, icon : Element msg } -> Element msg
front_ { label, type_, icon } =
    Element.el
        [ width <| px 80
        , height <| px 120
        , Element.Background.color white
        , Element.Border.rounded 8
        , Theme.Theme.boxShadow
        , Element.Font.color Theme.Colors.accent
        , Element.Font.bold
        , Element.Font.size 10
        , noTextShadow
        , padding 4
        ]
    <|
        column
            [ padding 4
            , Element.Border.rounded 8
            , Element.Border.solid
            , Element.Border.color Theme.Colors.accent
            , Element.Border.width 2
            , width fill
            , height fill
            ]
            [ Element.text label
            , el [ centerX, centerY ] <| icon
            , el [ alignRight ] <| Element.text label
            ]


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
