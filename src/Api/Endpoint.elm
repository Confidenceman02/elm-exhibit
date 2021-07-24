module Api.Endpoint exposing (Endpoint, elmPackageUrl, lambdaEndpoint, lambdaUrl, unwrap)

import ElmLangPackage exposing (ElmLangPackage)
import Url.Builder exposing (QueryParameter)


type Endpoint
    = Endpoint String


unwrap : Endpoint -> String
unwrap (Endpoint ep) =
    ep


lambdaEndpoint : String
lambdaEndpoint =
    "/.netlify/functions"


elmLangPackagesPath : String
elmLangPackagesPath =
    "https://package.elm-lang.org/packages"


elmPackageUrl : ElmLangPackage -> String
elmPackageUrl package =
    Url.Builder.crossOrigin elmLangPackagesPath [ package.name, "latest" ] []


lambdaUrl : List String -> List QueryParameter -> Endpoint
lambdaUrl path params =
    Url.Builder.relative (lambdaEndpoint :: path) params
        |> Endpoint
