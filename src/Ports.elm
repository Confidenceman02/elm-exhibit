port module Ports exposing (decodeRefererFromStateParam, decodedRefererFromStateParam)

import Json.Encode as Encode


port decodeRefererFromStateParam : String -> Cmd msg


port decodedRefererFromStateParam : (Encode.Value -> msg) -> Sub msg
