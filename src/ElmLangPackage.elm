module ElmLangPackage exposing (ElmLangPackage, decoder)

import Json.Decode as Decode
import Json.Decode.Pipeline exposing (required)


type alias ElmLangPackage =
    { name : String
    }


decoder : Decode.Decoder ElmLangPackage
decoder =
    Decode.succeed ElmLangPackage
        |> required "name" Decode.string
