module Viewer exposing (Cred, Viewer, credDecoder, credentials, getAvatarUrl, getUsername, init, isUsername)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)


type Viewer
    = Viewer Cred


type Cred
    = Cred Credentials


type alias Credentials =
    { username : String
    , userId : Int
    , avatarUrl : String
    }


init : Cred -> Viewer
init cred =
    Viewer cred


credentials : Viewer -> Cred
credentials (Viewer creds) =
    creds


credentialsDecoder : Decoder Credentials
credentialsDecoder =
    Decode.succeed Credentials
        |> required "username" Decode.string
        |> required "userId" Decode.int
        |> required "avatarUrl" Decode.string


credDecoder : Decoder Cred
credDecoder =
    Decode.map Cred credentialsDecoder


getAvatarUrl : Viewer -> String
getAvatarUrl (Viewer (Cred creds)) =
    creds.avatarUrl


getUsername : Viewer -> String
getUsername (Viewer (Cred creds)) =
    creds.username


isUsername : String -> Viewer -> Bool
isUsername v viewer =
    getUsername viewer == v
