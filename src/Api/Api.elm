module Api.Api exposing (get)

import Api.Endpoint exposing (Endpoint, unwrap)
import Http
import Json.Decode exposing (Decoder)


get : Endpoint -> (Result Http.Error a -> msg) -> Decoder a -> Cmd msg
get url toMsg decoder =
    Http.get { url = unwrap url, expect = Http.expectJson toMsg decoder }
