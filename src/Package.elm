module Package exposing (Package, toString, urlParser)

import Url.Parser as Parser exposing (Parser)


type Package
    = Package String


urlParser : Parser (Package -> a) a
urlParser =
    Parser.map Package Parser.string


toString : Package -> String
toString (Package a) =
    a
