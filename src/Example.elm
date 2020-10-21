module Example exposing (CompiledExample, Example, ExampleError(..), FoundAuthor, Id, build, fetch)

import Api.Api as Api
import Api.Endpoint as Endpoint
import Author as Author exposing (Author)
import Http exposing (Response)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Package as Package exposing (Package)
import Url.Builder as UrlBuilder exposing (QueryParameter)


type Id
    = Id String


type alias Example =
    { id : Id
    , name : String
    , description : String
    }


type CompiledExample
    = CompiledExample String


type ExampleError
    = ExampleBuildFailed
    | AuthorNotFound Author Package FoundAuthor
    | PackageNotFound Author Package
    | AuthorAndPackageNotFound Author Package
    | KeineAhnung



-- So we found the package but it has a different author


type alias FoundAuthor =
    Author


exampleDecoder : Decoder Example
exampleDecoder =
    Decode.succeed Example
        |> required "id" (Decode.map Id Decode.string)
        |> required "name" Decode.string
        |> required "description" Decode.string


examplesDecoder : Decoder (List Example)
examplesDecoder =
    Decode.field "examples" (Decode.list exampleDecoder)


compiledExample : Decoder CompiledExample
compiledExample =
    Decode.map CompiledExample Decode.string


authorNotFoundDecoder : Decoder Author
authorNotFoundDecoder =
    Decode.at [ "foundAuthor" ] Author.decoder


mapTagToExampleError : Author -> Package -> String -> Decoder ExampleError
mapTagToExampleError author package tag =
    case tag of
        "ExampleBuildFailed" ->
            Decode.succeed ExampleBuildFailed

        "AuthorNotFound" ->
            Decode.map (AuthorNotFound author package) authorNotFoundDecoder

        "PackageNotFound" ->
            Decode.succeed (PackageNotFound author package)

        "AuthorAndPackageNotFound" ->
            Decode.succeed (AuthorAndPackageNotFound author package)

        _ ->
            Decode.succeed KeineAhnung


errorBodyDecoder : Author -> Package -> Decoder ExampleError
errorBodyDecoder author package =
    Decode.field "tag" Decode.string
        |> Decode.andThen (mapTagToExampleError author package)


decodeResponseString : Author -> Package -> Decoder a -> Response String -> Result ExampleError a
decodeResponseString author package decoder response =
    case response of
        Http.BadStatus_ _ body ->
            case Decode.decodeString (errorBodyDecoder author package) body of
                Ok errorBody ->
                    Err errorBody

                Err _ ->
                    Err KeineAhnung

        Http.GoodStatus_ _ body ->
            case Decode.decodeString decoder body of
                Ok decodedBody ->
                    Ok decodedBody

                Err err ->
                    Err KeineAhnung

        _ ->
            Err KeineAhnung


nameQueryToParam : Example -> QueryParameter
nameQueryToParam example =
    UrlBuilder.string "example" example.name


fetch : (Result ExampleError (List Example) -> msg) -> Author -> Package -> Cmd msg
fetch toMsg author package =
    Api.get
        (Endpoint.lambdaUrl [ "examples" ]
            [ Author.toQueryParam author, Package.toQueryParam package ]
        )
        toMsg
        (decodeResponseString author package examplesDecoder)


build : (Result ExampleError CompiledExample -> msg) -> Author -> Package -> Example -> Cmd msg
build toMsg author package example =
    Api.get
        (Endpoint.lambdaUrl [ "build-example" ]
            [ Author.toQueryParam author, Package.toQueryParam package, nameQueryToParam example ]
        )
        toMsg
        (decodeResponseString author package compiledExample)
