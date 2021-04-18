module Exhibit exposing (Exhibit, ExhibitError(..), exhibitsDecoder, fetchAuthorExhibits, toQueryParam, toString, urlParser)

import Api.Api as Api
import Api.Endpoint as Endpoint
import Author exposing (Author)
import Http exposing (Response)
import Json.Decode as Decode exposing (Decoder)
import Url.Builder as UrlBuilder exposing (QueryParameter)
import Url.Parser as Parser exposing (Parser)


type Exhibit
    = Exhibit String


type ExhibitError
    = AuthorNotFound Author
    | MissingAuthor
    | KeineAhnung


urlParser : Parser (Exhibit -> a) a
urlParser =
    Parser.map Exhibit Parser.string


toString : Exhibit -> String
toString (Exhibit a) =
    a


exhibitDecoder : Decoder Exhibit
exhibitDecoder =
    Decode.map Exhibit Decode.string


exhibitsDecoder : Decoder (List Exhibit)
exhibitsDecoder =
    Decode.field "exhibits" (Decode.list exhibitDecoder)


toQueryParam : Exhibit -> QueryParameter
toQueryParam =
    toString >> UrlBuilder.string "package"


mapTagToExhibitError : Author -> String -> Decoder ExhibitError
mapTagToExhibitError author tag =
    case tag of
        "AuthorNotFound" ->
            Decode.succeed (AuthorNotFound author)

        _ ->
            Decode.succeed KeineAhnung


errorBodyDecoder : Author -> Decoder ExhibitError
errorBodyDecoder author =
    Decode.field "tag" Decode.string
        |> Decode.andThen (mapTagToExhibitError author)


decodeResponseToString : Author -> Decoder a -> Response String -> Result ExhibitError a
decodeResponseToString author goodStatusDecoder response =
    case response of
        Http.BadStatus_ _ body ->
            case Decode.decodeString (errorBodyDecoder author) body of
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



-- REQUEST


fetchAuthorExhibits : (Result ExhibitError (List Exhibit) -> msg) -> Author -> Cmd msg
fetchAuthorExhibits toMsg author =
    Api.get
        (Endpoint.lambdaUrl [ "author-exhibits" ]
            [ Author.toQueryParam author ]
        )
        toMsg
        (decodeResponseToString author exhibitsDecoder)
