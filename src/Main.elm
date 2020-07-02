module Main exposing (..)

import Api as Api
import Browser as Browser exposing (Document)
import Browser.Navigation as Navigation
import Header as Header
import Html.Styled as Styled
import Json.Encode as Encode
import Pages.Examples as ExamplesPage
import Route as Route exposing (Route)
import Url


type Msg
    = Noop
    | Example ExamplesPage.Msg


type Model
    = Home ExamplesPage.Model
    | NotFound


init : Encode.Value -> Url.Url -> Navigation.Key -> ( Model, Cmd Msg )
init entryData url navKey =
    changeRouteTo (Route.fromUrl url)


changeRouteTo : Maybe Route -> ( Model, Cmd Msg )
changeRouteTo maybeRoute =
    case maybeRoute of
        Nothing ->
            ( NotFound, Cmd.none )

        Just Route.Examples ->
            ( Home ExamplesPage.init, Cmd.none )


view : Model -> Document Msg
view _ =
    { title = "Elm Exhibit"
    , body = [ header, Styled.map Example ExamplesPage.view ] |> List.map Styled.toUnstyled
    }


header : Styled.Html msg
header =
    Header.view <| Header.package Api.hardCodedPackage


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Example packageMsg ->
            ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


main : Program Encode.Value Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = \_ -> Noop
        , onUrlChange = \_ -> Noop
        }
