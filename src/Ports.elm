port module Ports exposing (decodeRefererFromStateParam, decodedRefererFromStateParam)


port decodeRefererFromStateParam : String -> Cmd msg


port decodedRefererFromStateParam : (String -> msg) -> Sub msg
