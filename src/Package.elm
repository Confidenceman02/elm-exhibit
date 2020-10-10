module Package exposing (Package, toQueryParam, toString, urlParser)

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


toQueryParam : Package -> QueryParameter
toQueryParam =
    toString >> UrlBuilder.string "package"
