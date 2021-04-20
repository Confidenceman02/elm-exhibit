module Exhibit exposing (Exhibit, toQueryParam, toString, urlParser)

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


toQueryParam : Exhibit -> QueryParameter
toQueryParam =
    toString >> UrlBuilder.string "package"
