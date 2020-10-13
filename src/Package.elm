module Package exposing (Package, decoder, toQueryParam, toString, urlParser)

import Json.Decode as Decode exposing (Decoder)
import Url.Builder as UrlBuilder exposing (QueryParameter)
import Url.Parser as Parser exposing (Parser)


type Package
    = Package String


urlParser : Parser (Package -> a) a
urlParser =
    Parser.map Package Parser.string


toString : Package -> String
toString (Package a) =
    a


decoder : Decoder Package
decoder =
    Decode.map Package Decode.string


toQueryParam : Package -> QueryParameter
toQueryParam =
    toString >> UrlBuilder.string "package"
