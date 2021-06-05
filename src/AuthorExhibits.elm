module AuthorExhibits exposing (AuthorExhibit, AuthorExhibitsError(..), fetch)

import Api.Api as Api
import Api.Endpoint as Endpoint
import Author exposing (Author)
import ElmLangPackage
import Http exposing (Response)
import Json.Decode as Decode exposing (Decoder)


type AuthorExhibit
    = AuthorExhibit String


type AuthorExhibitsError
    = AuthorNotFound Author
    | AuthorNotRegisteredIsElmLangPackageAuthor Author (List ElmLangPackage.ElmLangPackage)
    | MissingAuthorParam
    | KeineAhnung


exhibitDecoder : Decoder AuthorExhibit
exhibitDecoder =
    Decode.map AuthorExhibit Decode.string


exhibitsDecoder : Decoder (List AuthorExhibit)
exhibitsDecoder =
    Decode.field "exhibits" (Decode.list exhibitDecoder)


elmLangPackageDecoder : Decoder (List ElmLangPackage.ElmLangPackage)
elmLangPackageDecoder =
    Decode.at [ "packages" ] (Decode.list ElmLangPackage.decoder)


mapTagToExhibitError : Author -> String -> Decoder AuthorExhibitsError
mapTagToExhibitError author tag =
    case tag of
        "AuthorNotFound" ->
            Decode.succeed (AuthorNotFound author)

        "AuthorNotFoundWithElmLangPackages" ->
            Decode.map (AuthorNotRegisteredIsElmLangPackageAuthor author) elmLangPackageDecoder

        _ ->
            Decode.succeed KeineAhnung


errorBodyDecoder : Author -> Decoder AuthorExhibitsError
errorBodyDecoder author =
    Decode.field "tag" Decode.string
        |> Decode.andThen (mapTagToExhibitError author)


decodeResponseToString : Author -> Decoder a -> Response String -> Result AuthorExhibitsError a
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

                Err _ ->
                    Err KeineAhnung

        _ ->
            Err KeineAhnung


fetch : (Result AuthorExhibitsError (List AuthorExhibit) -> msg) -> Author -> Cmd msg
fetch toMsg author =
    Api.get
        (Endpoint.lambdaUrl [ "author-exhibits" ]
            [ Author.toQueryParam author ]
        )
        toMsg
        (decodeResponseToString author exhibitsDecoder)
