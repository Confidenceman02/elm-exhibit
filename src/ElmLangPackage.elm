module ElmLangPackage exposing (ElmLangPackage, decoder)

import Json.Decode as Decode
import Json.Decode.Pipeline exposing (required)


type alias ElmLangPackage =
    { name : String
    }


decoder : Decoder ElmLangPackage
decoder =
    Deocde.succeed ElmLangPackage
        |> required "name" Decode.string
