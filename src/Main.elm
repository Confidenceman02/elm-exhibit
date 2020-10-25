module Main exposing (view)

import Browser as Browser exposing (Document)
import Browser.Navigation as Nav
import Context exposing (Context)
import Effect exposing (Effect)
import Header
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
    | RefreshedSession (Result Session.SessionError Session.SessionSuccess)
    | SessionAuthorizing (Result Session.SessionError Session.SessionSuccess)


type Model
    = Examples ExamplesPage.Model
    | Home HomePage.Model
    | NotFound Context


init : Encode.Value -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url navKey =
    let
        ( refreshSessionCmd, session ) =
            Session.refresh RefreshedSession
    in
    changeRouteTo (Route.fromUrl url) (Context.toContext url navKey session)
        |> Tuple.mapSecond (\cmds -> Cmd.batch [ cmds, refreshSessionCmd ])


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
            ( Examples model, Cmd.batch [ Cmd.map GotExamplesMsg cmds ] )

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
            viewPage
                (Page.Examples
                    examplesModel.author
                    examplesModel.package
                    examplesModel.context.session
                    ExamplesPage.toHeaderMsg
                )
                GotExamplesMsg
                (ExamplesPage.view examplesModel)

        Home _ ->
            viewPage Page.Home GotHomeMsg HomePage.view

        NotFound _ ->
            NotFoundPage.view


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( GotExamplesMsg examplesMsg, Examples examples ) ->
            ExamplesPage.update examplesMsg examples
                |> updateWithEffect Examples GotExamplesMsg exampleEffectHandler

        ( ClickedLink urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl (Context.navKey <| toContext model) (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        ( ChangedUrl url, _ ) ->
            changeRouteTo (Route.fromUrl url) (toContext model)

        ( RefreshedSession result, Examples m ) ->
            let
                updatedModel =
                    { m | context = Context.updateSession updatedSession m.context }

                ( sessionCmd, updatedSession ) =
                    Session.fromResult result
            in
            ( Examples updatedModel, sessionCmd )

        ( SessionAuthorizing result, Examples m ) ->
            let
                updatedModel =
                    { m | context = Context.updateSession updatedSession m.context }

                ( sessionCmd, updatedSession ) =
                    Session.fromResult result
            in
            ( Examples updatedModel, sessionCmd )

        _ ->
            ( model, Cmd.none )


updateWith : (subModel -> Model) -> (subMsg -> Msg) -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toModel toMsg ( subModel, subCmd ) =
    ( toModel subModel, Cmd.map toMsg subCmd )


updateWithEffect : (subModel -> Model) -> (subMsg -> Msg) -> Effect.Handler subModel effect Msg -> ( subModel, Cmd subMsg, Effect effect ) -> ( Model, Cmd Msg )
updateWithEffect toModel toMsg effectHandler ( subModel, subCmd, effect ) =
    let
        ( subModelWithEffect, effectCmd ) =
            Effect.evaluate effectHandler subModel effect
    in
    ( toModel subModelWithEffect, Cmd.batch [ Cmd.map toMsg subCmd, effectCmd ] )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


exampleEffectHandler : Effect.Handler ExamplesPage.Model ExamplesPage.Effect Msg
exampleEffectHandler model effect =
    case effect of
        ExamplesPage.HeaderEffect headerEffect ->
            headerEffectHandler model headerEffect


headerEffectHandler : Effect.Handler ExamplesPage.Model Header.HeaderEffect Msg
headerEffectHandler model effect =
    case effect of
        Header.SignInEffect ->
            let
                ( sessionCmd, session ) =
                    Session.login SessionAuthorizing

                updatedContext =
                    Context.updateSession session model.context
            in
            ( { model | context = updatedContext }, sessionCmd )

        Header.SignOutEffect ->
            ( model, Cmd.none )


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
