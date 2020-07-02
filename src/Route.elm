module Route exposing (Route(..), fromUrl)

import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), oneOf, s)


type Route
    = Examples


parser : Parser.Parser (Route -> a) a
parser =
    oneOf
        [ Parser.map Examples Parser.top
        ]


fromUrl : Url -> Maybe Route
fromUrl url =
    Parser.parse parser url
