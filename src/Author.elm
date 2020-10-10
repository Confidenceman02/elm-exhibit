module Author exposing (Author, toQueryParam, toString, urlParser)

import Url.Builder as UrlBuilder exposing (QueryParameter)
import Url.Parser as Parser exposing (Parser)


type Author
    = Author String


toString : Author -> String
toString (Author a) =
    a


urlParser : Parser (Author -> a) a
urlParser =
    Parser.map Author Parser.string


toQueryParam : Author -> QueryParameter
toQueryParam =
    toString >> UrlBuilder.string "author"
