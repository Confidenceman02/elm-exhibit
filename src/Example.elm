module Example exposing (CompiledExample, Example, ExampleError(..), FoundAuthor, Id, build, fetch)

import Api.Api as Api
import Api.Endpoint as Endpoint
import Author as Author exposing (Author)
import Exhibit as Exhibit exposing (Exhibit)
import Http exposing (Response)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
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
    = AuthorNotFound Author Exhibit FoundAuthor
    | ExhibitNotFound Author Exhibit
    | AuthorAndExhibitNotFound Author Exhibit
    | KeineAhnung



-- So we found the exhibit but it has a different author


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


mapTagToExampleError : Author -> Exhibit -> String -> Decoder ExampleError
mapTagToExampleError author exhibit tag =
    case tag of
        "AuthorNotFound" ->
            Decode.map (AuthorNotFound author exhibit) authorNotFoundDecoder

        "ExhibitNotFound" ->
            Decode.succeed (ExhibitNotFound author exhibit)

        "AuthorAndExhibitNotFound" ->
            Decode.succeed (AuthorAndExhibitNotFound author exhibit)

        _ ->
            Decode.succeed KeineAhnung


errorBodyDecoder : Author -> Exhibit -> Decoder ExampleError
errorBodyDecoder author exhibit =
    Decode.field "tag" Decode.string
        |> Decode.andThen (mapTagToExampleError author exhibit)


decodeResponseString : Author -> Exhibit -> Decoder a -> Response String -> Result ExampleError a
decodeResponseString author exhibit goodStatusDecoder response =
    case response of
        Http.BadStatus_ _ body ->
            case Decode.decodeString (errorBodyDecoder author exhibit) body of
                Ok errorBody ->
                    Err errorBody

                Err _ ->
                    Err KeineAhnung

        Http.GoodStatus_ _ body ->
            case Decode.decodeString goodStatusDecoder body of
                Ok decodedBody ->
                    Ok decodedBody

                Err err ->
                    Err KeineAhnung

        _ ->
            Err KeineAhnung


nameQueryToParam : Example -> QueryParameter
nameQueryToParam example =
    UrlBuilder.string "example" example.name


fetch : (Result ExampleError (List Example) -> msg) -> Author -> Exhibit -> Cmd msg
fetch toMsg author exhibit =
    Api.get
        (Endpoint.lambdaUrl [ "examples" ]
            [ Author.toQueryParam author, Exhibit.toQueryParam exhibit ]
        )
        toMsg
        (decodeResponseString author exhibit examplesDecoder)


build : (Result ExampleError CompiledExample -> msg) -> Author -> Exhibit -> Example -> Cmd msg
build toMsg author exhibit example =
    Api.get
        (Endpoint.lambdaUrl [ "build-example" ]
            [ Author.toQueryParam author, Exhibit.toQueryParam exhibit, nameQueryToParam example ]
        )
        toMsg
        (decodeResponseString author exhibit compiledExample)
