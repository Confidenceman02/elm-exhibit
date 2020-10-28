module Route exposing (Route(..), fromUrl)

import Author as Author exposing (Author)
import GithubAuth
import Package as Package exposing (Package)
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), (<?>), oneOf, s)


type Route
    = Examples Author Package
    | AuthGithubRedirect (Maybe GithubAuth.CallBackParams)
    | Home


parser : Parser.Parser (Route -> a) a
parser =
    oneOf
        [ Parser.map Home Parser.top
        , Parser.map Examples (s "example" </> Author.urlParser </> Package.urlParser)
        , Parser.map AuthGithubRedirect (s "auth" </> s "github" </> s "callback" <?> GithubAuth.callBackParamsParser)
        ]


fromUrl : Url -> Maybe Route
fromUrl url =
    Parser.parse parser url
