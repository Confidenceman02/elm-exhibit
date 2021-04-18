module Route exposing (Route(..), fromUrl, isAuthGithubRedirect)

import Author as Author exposing (Author)
import Exhibit as Package exposing (Exhibit)
import GithubAuth
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), (<?>), oneOf, s)


type Route
    = Exhibit Author Exhibit
    | AuthorExhibits Author
    | AuthGithubRedirect (Maybe GithubAuth.CallBackParams)
    | Home


parser : Parser.Parser (Route -> a) a
parser =
    oneOf
        [ Parser.map Home Parser.top
        , Parser.map Exhibit (s "exhibit" </> Author.urlParser </> Package.urlParser)
        , Parser.map AuthorExhibits Author.urlParser
        , Parser.map AuthGithubRedirect (s "auth" </> s "github" </> s "callback" <?> GithubAuth.callBackParamsParser)
        ]


fromUrl : Url -> Maybe Route
fromUrl url =
    Parser.parse parser url


isAuthGithubRedirect : Route -> Bool
isAuthGithubRedirect route =
    case route of
        AuthGithubRedirect _ ->
            True

        _ ->
            False
