module Api.Api exposing (get)

import Api.Endpoint exposing (Endpoint, unwrap)
import Http exposing (Response)
import Json.Decode exposing (Decoder)


get : Endpoint -> (Result x a -> msg) -> (Response String -> Result x a) -> Cmd msg
get url toMsg decoder =
    Http.get { url = unwrap url, expect = Http.expectStringResponse toMsg decoder }
