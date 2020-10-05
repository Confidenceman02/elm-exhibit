module Example exposing (Example, Id, fetch)

import Api.Api as Api
import Api.Endpoint as Endpoint
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Url.Builder


type Id
    = Id String


type alias Example =
    { id : Id
    , name : String
    , description : String
    }


decoder : Decoder Example
decoder =
    Decode.succeed Example
        |> required "id" (Decode.map Id Decode.string)
        |> required "name" Decode.string
        |> required "descriptions" Decode.string


fetch : (Result Http.Error (List Example) -> msg) -> Cmd msg
fetch toMsg =
    Api.get (Endpoint.lambdaUrl [ "examples" ] []) toMsg (Decode.list decoder)
