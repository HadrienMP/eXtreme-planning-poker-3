module Domain.RoomMessage exposing (..)

import Json.Encode as Json

type alias RoomMessage =
    { room : String
    , data : Json.Value
    }
