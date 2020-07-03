module Main exposing (..)

import Api as Api
import Browser as Browser exposing (Document)
import Browser.Navigation as Navigation
import Header as Header
import Html exposing (text)
import Html.Styled as Styled
import Json.Encode as Encode
import Page
import Pages.Examples as ExamplesPage
import Pages.NotFound as NotFoundPage
import Route as Route exposing (Route)
import Url


type Msg
    = Noop
    | GotExampleMsg ExamplesPage.Msg


type Model
    = Examples ExamplesPage.Model
    | Home
    | NotFound


init : Encode.Value -> Url.Url -> Navigation.Key -> ( Model, Cmd Msg )
init entryData url navKey =
    changeRouteTo (Route.fromUrl url)


changeRouteTo : Maybe Route -> ( Model, Cmd Msg )
changeRouteTo maybeRoute =
    case maybeRoute of
        Nothing ->
            ( NotFound, Cmd.none )

        Just (Route.Examples package) ->
            ( Examples ExamplesPage.init, Cmd.none )

        -- TODO: Create home page
        Just Route.Home ->
            ( Home, Cmd.none )


view : Model -> Document Msg
view model =
    let
        viewPage page toMsg config =
            let
                { title, body } =
                    Page.view page config
            in
            { title = title
            , body = List.map (Styled.map toMsg) body |> List.map Styled.toUnstyled
            }
    in
    case model of
        Examples examplesModal ->
            viewPage Page.Home GotExampleMsg ExamplesPage.view

        Home ->
            { title = "Home", body = [ text "This is home page" ] }

        NotFound ->
            NotFoundPage.view


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotExampleMsg packageMsg ->
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
