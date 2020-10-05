module Api.Endpoint exposing (Endpoint, lambdaEndpoint, lambdaUrl, unwrap)

import Url.Builder exposing (QueryParameter)


type Endpoint
    = Endpoint String


unwrap : Endpoint -> String
unwrap (Endpoint ep) =
    ep


lambdaEndpoint : String
lambdaEndpoint =
    "/.netlify/functions"


lambdaUrl : List String -> List QueryParameter -> Endpoint
lambdaUrl path params =
    Url.Builder.relative (lambdaEndpoint :: path) params
        |> Endpoint
