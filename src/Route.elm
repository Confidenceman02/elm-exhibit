module Route exposing (Route(..), fromUrl)

import Author as Author exposing (Author)
import Package as Package exposing (Package)
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), oneOf, s)


type Route
    = Examples Author Package
    | Home


parser : Parser.Parser (Route -> a) a
parser =
    oneOf
        [ Parser.map Home Parser.top
        , Parser.map Examples (s "examples" </> Author.urlParser </> Package.urlParser)
        ]


fromUrl : Url -> Maybe Route
fromUrl url =
    Parser.parse parser url
