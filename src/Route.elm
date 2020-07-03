module Route exposing (Route(..), fromUrl)

import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), oneOf, s)


type Route
    = Examples Package
    | Home


type Package
    = Package String


parser : Parser.Parser (Route -> a) a
parser =
    oneOf
        [ Parser.map Home Parser.top
        , Parser.map Examples (s "examples" </> Parser.map Package Parser.string)
        ]


fromUrl : Url -> Maybe Route
fromUrl url =
    Parser.parse parser url
