module Theme.Colors exposing (..)

import Element exposing (rgb, rgba, toRgb)
import Element.HexColor exposing (hex)


black : Element.Color
black =
    hexToRgba "000000"


accent : Element.Color
accent =
    -- hexToRgba "#1ad5bf"
    hexToRgba "#00B3A1"
    


text : Element.Color
text =
    white


darken : Element.Color -> Element.Color
darken color =
    color
        |> toRgb
        |> (\{ red, green, blue, alpha } -> rgba (red * 0.9) (green * 0.9) (blue * 0.9) alpha)


moreTransparent : Int -> Element.Color -> Element.Color
moreTransparent amount color =
    color
        |> toRgb
        |> (\{ red, green, blue, alpha } -> rgba red green blue (alpha * (toFloat (10 - amount) / 10)))


placeholder : Element.Color
placeholder =
    white |> moreTransparent 2


white : Element.Color
white =
    hexToRgba "#ffffff"


transparent : Element.Color
transparent =
    rgba 0 0 0 0


hexToRgba : String -> Element.Color
hexToRgba value =
    hex value |> Maybe.withDefault (rgb 0 0 0)
