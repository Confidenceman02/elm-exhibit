module Example exposing (Example, ExampleError, Id, fetch)

import Api.Api as Api
import Api.Endpoint as Endpoint
import Author exposing (Author)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Package exposing (Package)


type Id
    = Id String


type alias Example =
    { id : Id
    , name : String
    , description : String
    }


type ExampleError
    = ExampleBuildFailed
    | AuthorNotFound
    | PackageNotFound
    | AuthorAndPackageNotFound
    | KeineAhnung


decoder : Decoder Example
decoder =
    Decode.succeed Example
        |> required "id" (Decode.map Id Decode.string)
        |> required "name" Decode.string
        |> required "description" Decode.string


fetch : (Result Http.Error (List Example) -> msg) -> Author -> Package -> Cmd msg
fetch toMsg author package =
    Api.get
        (Endpoint.lambdaUrl [ "examples" ]
            [ Author.toQueryParam author, Package.toQueryParam package ]
        )
        toMsg
        (Decode.field "examples" <| Decode.list decoder)
