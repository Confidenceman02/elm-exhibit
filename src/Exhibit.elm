module Exhibit exposing (Exhibit, decoder, toQueryParam, toString, urlParser)

import Json.Decode as Decode exposing (Decoder)
import Url.Builder as UrlBuilder exposing (QueryParameter)
import Url.Parser as Parser exposing (Parser)


type Exhibit
    = Exhibit String


urlParser : Parser (Exhibit -> a) a
urlParser =
    Parser.map Exhibit Parser.string


toString : Exhibit -> String
toString (Exhibit a) =
    a


decoder : Decoder Exhibit
decoder =
    Decode.map Exhibit Decode.string


toQueryParam : Exhibit -> QueryParameter
toQueryParam =
    toString >> UrlBuilder.string "package"
