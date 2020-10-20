module Main exposing (view)

import Browser as Browser exposing (Document)
import Browser.Navigation as Nav
import Context exposing (Context)
import Html.Styled as Styled
import Json.Encode as Encode
import Page
import Pages.Example as ExamplesPage
import Pages.Home as HomePage
import Pages.NotFound as NotFoundPage
import Route as Route exposing (Route)
import Session
import Url exposing (Url)


type Msg
    = Noop
    | ClickedLink Browser.UrlRequest
    | ChangedUrl Url
    | GotExamplesMsg ExamplesPage.Msg
    | GotHomeMsg HomePage.Msg


type Model
    = Examples ExamplesPage.Model
    | Home HomePage.Model
    | NotFound Context


init : Encode.Value -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url navKey =
    changeRouteTo (Route.fromUrl url) (Context.toContext url navKey Session.init)


changeRouteTo : Maybe Route -> Context -> ( Model, Cmd Msg )
changeRouteTo maybeRoute context =
    case maybeRoute of
        Nothing ->
            ( NotFound context, Cmd.none )

        Just (Route.Examples author package) ->
            let
                ( model, cmds ) =
                    ExamplesPage.init author package context
            in
            ( Examples model, Cmd.map GotExamplesMsg cmds )

        -- TODO: Create home page
        Just Route.Home ->
            let
                model =
                    HomePage.init context
            in
            ( Home model, Cmd.none )


toContext : Model -> Context
toContext model =
    case model of
        Examples m ->
            ExamplesPage.toContext m

        Home m ->
            HomePage.toContext m

        NotFound context ->
            context


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
            viewPage (Page.Examples examplesModel.author examplesModel.package examplesModel.context.session) GotExamplesMsg (ExamplesPage.view examplesModel)

        Home _ ->
            viewPage Page.Home GotHomeMsg HomePage.view

        NotFound _ ->
            NotFoundPage.view


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( GotExamplesMsg examplesMsg, Examples examples ) ->
            ExamplesPage.update examplesMsg examples
                |> updateWith Examples GotExamplesMsg

        ( ClickedLink urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl (Context.navKey <| toContext model) (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        ( ChangedUrl url, _ ) ->
            changeRouteTo (Route.fromUrl url) (toContext model)

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
        , onUrlRequest = ClickedLink
        , onUrlChange = ChangedUrl
        }
