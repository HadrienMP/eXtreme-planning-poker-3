module Theme.Colors exposing (..)

import Element exposing (rgba)
import Element exposing (rgb)
import Element.HexColor exposing (hex)


black : Element.Color
black =
    hexToRgba "000000"


accent : Element.Color
accent =
    hexToRgba "#08AEEA"


text : Element.Color
text =
    white


white : Element.Color
white =
    hexToRgba "#ffffff"


transparent : Element.Color
transparent =
    rgba 0 0 0 0


hexToRgba : String -> Element.Color
hexToRgba value =
    hex value |> Maybe.withDefault (rgb 0 0 0)
