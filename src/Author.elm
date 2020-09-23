module Author exposing (Author, toString, urlParser)

import Url.Parser as Parser exposing (Parser)


type Author
    = Author String


toString : Author -> String
toString (Author a) =
    a


urlParser : Parser (Author -> a) a
urlParser =
    Parser.map Author Parser.string
