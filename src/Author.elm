module Author exposing (Author, decoder, toQueryParam, toString, urlParser)

import Json.Decode as Decode exposing (Decoder)
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


decoder : Decoder Author
decoder =
    Decode.map Author Decode.string


toQueryParam : Author -> QueryParameter
toQueryParam =
    toString >> UrlBuilder.string "author"
