module Main exposing (..)

import Browser as Browser exposing (Document)
import Browser.Navigation as Navigation
import Context exposing (Context)
import Html exposing (text)
import Html.Styled as Styled
import Json.Encode as Encode
import Page
import Pages.Example as ExamplesPage
import Pages.Home as HomePage
import Pages.NotFound as NotFoundPage
import Route as Route exposing (Route)
import Url


type Msg
    = Noop
    | GotExamplesMsg ExamplesPage.Msg
    | GotHomeMsg HomePage.Msg


type Model
    = Examples ExamplesPage.Model
    | Home
    | NotFound


init : Encode.Value -> Url.Url -> Navigation.Key -> ( Model, Cmd Msg )
init entryData url navKey =
    changeRouteTo (Route.fromUrl url) (Context.toContext url)


changeRouteTo : Maybe Route -> Context -> ( Model, Cmd Msg )
changeRouteTo maybeRoute context =
    case maybeRoute of
        Nothing ->
            ( NotFound, Cmd.none )

        Just (Route.Examples author package) ->
            let
                ( model, cmds ) =
                    ExamplesPage.init author package context
            in
            ( Examples model, Cmd.map GotExamplesMsg cmds )

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
        Examples examplesModel ->
            viewPage (Page.Examples examplesModel.author examplesModel.packageName) GotExamplesMsg (ExamplesPage.view examplesModel)

        Home ->
            viewPage Page.Home GotHomeMsg HomePage.view

        NotFound ->
            NotFoundPage.view


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( GotExamplesMsg examplesMsg, Examples examples ) ->
            ExamplesPage.update examplesMsg examples
                |> updateWith Examples GotExamplesMsg

        _ ->
            ( model, Cmd.none )


updateWith : (subModel -> Model) -> (subMsg -> Msg) -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toModel toMsg ( subModel, subCmd ) =
    ( toModel subModel, Cmd.map toMsg subCmd )


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
