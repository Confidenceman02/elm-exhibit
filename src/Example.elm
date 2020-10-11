module Example exposing (Example, ExampleError, Id, fetch)

import Api.Api as Api
import Api.Endpoint as Endpoint
import Author exposing (Author)
import Http exposing (Response)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Package exposing (Package)


type Id
    = Id String


type alias Example =
    { id : Id
    , name : String
    , description : String
    }


type ExampleError
    = ExampleBuildFailed
    | AuthorNotFound
    | PackageNotFound
    | AuthorAndPackageNotFound
    | KeineAhnung


type alias ErrorBody =
    { tag : ExampleError
    }


exampleDecoder : Decoder Example
exampleDecoder =
    Decode.succeed Example
        |> required "id" (Decode.map Id Decode.string)
        |> required "name" Decode.string
        |> required "description" Decode.string


examplesDecoder : Decoder (List Example)
examplesDecoder =
    Decode.field "examples" (Decode.list exampleDecoder)


mapTagToExampleError : String -> Decoder ExampleError
mapTagToExampleError tag =
    case tag of
        "ExampleBuildFailed" ->
            Decode.succeed ExampleBuildFailed

        "AuthorNotFound" ->
            Decode.succeed AuthorNotFound

        "PackageNotFound" ->
            Decode.succeed PackageNotFound

        "AuthorAndPackageNotFound" ->
            Decode.succeed AuthorAndPackageNotFound

        _ ->
            Decode.succeed KeineAhnung


errorBodyDecoder : Decoder ErrorBody
errorBodyDecoder =
    Decode.succeed ErrorBody
        |> required "tag" (Decode.string |> Decode.andThen mapTagToExampleError)


decodeResponseString : Response String -> Result ExampleError (List Example)
decodeResponseString response =
    case response of
        Http.BadStatus_ _ body ->
            case Decode.decodeString errorBodyDecoder body of
                Ok errorBody ->
                    Err errorBody.tag

                Err err ->
                    Err KeineAhnung |> Debug.log (Decode.errorToString err)

        Http.GoodStatus_ _ body ->
            case Decode.decodeString examplesDecoder body of
                Ok decodedBody ->
                    Ok decodedBody

                Err _ ->
                    Err KeineAhnung

        _ ->
            Err KeineAhnung


fetch : (Result ExampleError (List Example) -> msg) -> Author -> Package -> Cmd msg
fetch toMsg author package =
    Api.get
        (Endpoint.lambdaUrl [ "examples" ]
            [ Author.toQueryParam author, Package.toQueryParam package ]
        )
        toMsg
        decodeResponseString
