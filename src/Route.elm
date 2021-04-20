module Route exposing (Route(..), authorExhibitLink, exhibitLink, fromUrl, isAuthGithubRedirect)

import Author as Author exposing (Author)
import Exhibit exposing (Exhibit)
import GithubAuth
import Url exposing (Url)
import Url.Builder
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
        , Parser.map Exhibit (s exhibitSlug </> Author.urlParser </> Exhibit.urlParser)
        , Parser.map AuthorExhibits Author.urlParser
        , Parser.map AuthGithubRedirect (s "auth" </> s "github" </> s "callback" <?> GithubAuth.callBackParamsParser)
        ]


fromUrl : Url -> Maybe Route
fromUrl url =
    Parser.parse parser url


exhibitSlug : String
exhibitSlug =
    "exhibit"


isAuthGithubRedirect : Route -> Bool
isAuthGithubRedirect route =
    case route of
        AuthGithubRedirect _ ->
            True

        _ ->
            False


authorExhibitLink : Author -> String
authorExhibitLink author =
    Url.Builder.relative [ Author.toString author ] []


exhibitLink : Author -> Exhibit -> String
exhibitLink author exhibit =
    Url.Builder.relative (exhibitSlug :: [ Author.toString author, Exhibit.toString exhibit ]) []
