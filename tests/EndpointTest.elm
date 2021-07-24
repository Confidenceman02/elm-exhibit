module EndpointTest exposing (..)

import Api.Endpoint exposing (elmPackageUrl)
import Expect
import Test exposing (Test, describe, test)


tests : Test
tests =
    describe "EndPoint"
        [ describe "elmPackageUrl"
            [ test "creates a url link to elm package" <|
                let
                    resolvePackageUrl =
                        elmPackageUrl { name = "Confidenceman02/elm-select" }
                in
                \() -> Expect.equal "https://package.elm-lang.org/packages/Confidenceman02/elm-select/latest" resolvePackageUrl
            ]
        ]
