module Viewer exposing (Cred, Viewer, credDecoder, init)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)


type Viewer
    = Viewer Cred


type Cred
    = Cred Credentials


type alias Credentials =
    { username : String
    , userId : String
    , avatarUrl : String
    }


init : Cred -> Viewer
init cred =
    Viewer cred


credentialsDecoder : Decoder Credentials
credentialsDecoder =
    Decode.succeed Credentials
        |> required "username" Decode.string
        |> required "userId" Decode.string
        |> required "avatarUrl" Decode.string


credDecoder : Decoder Cred
credDecoder =
    Decode.map Cred credentialsDecoder
