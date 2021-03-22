module Main exposing (view)

import Browser as Browser exposing (Document)
import Browser.Navigation as Nav
import Context exposing (Context)
import Effect exposing (Effect)
import Header
import Html.Styled as Styled
import Json.Encode as Encode
import Page
import Pages.AuthRedirect as AuthRedirectPage
import Pages.Example as ExamplePage
import Pages.Home as HomePage
import Pages.NotFound as NotFoundPage
import Route as Route exposing (Route)
import Session
import Url exposing (Url)
import Viewer


type Msg
    = Noop
    | ClickedLink Browser.UrlRequest
    | ChangedUrl Url
    | GotExampleMsg ExamplePage.Msg
    | GotHomeMsg HomePage.Msg
    | RefreshedSession (Result Session.SessionError Session.SessionSuccess)
    | SessionAuthorizing (Result Session.SessionError Session.SessionSuccess)
    | SessionDestroying (Result Session.SessionError Session.SessionSuccess)
    | GotAuthGithubRedirectMsg AuthRedirectPage.Msg


type Model
    = Example ExamplePage.Model
    | Home HomePage.Model
    | NotFound Context
    | AuthRedirect AuthRedirectPage.Model


init : Encode.Value -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url navKey =
    let
        route =
            Route.fromUrl url

        -- We dont want to be refreshing session if
        -- Github redirected user here after app acceptance flow because
        -- that means there is no session in the first place to refresh!
        ( refreshSessionCmd, session ) =
            case route of
                Just r ->
                    if Route.isAuthGithubRedirect r then
                        ( Cmd.none, Session.loggingIn )

                    else
                        Session.refresh RefreshedSession

                Nothing ->
                    ( Cmd.none, Session.init )
    in
    changeRouteTo route (Context.toContext url navKey session)
        |> Tuple.mapSecond (\cmds -> Cmd.batch [ cmds, refreshSessionCmd ])


changeRouteTo : Maybe Route -> Context -> ( Model, Cmd Msg )
changeRouteTo maybeRoute context =
    case maybeRoute of
        Nothing ->
            ( NotFound context, Cmd.none )

        Just (Route.Examples author package) ->
            let
                ( model, cmds ) =
                    ExamplePage.init author package context
            in
            ( Example model, Cmd.batch [ Cmd.map GotExampleMsg cmds ] )

        -- TODO: Create home page
        Just Route.Home ->
            let
                model =
                    HomePage.init context
            in
            ( Home model, Cmd.none )

        Just (Route.AuthGithubRedirect params) ->
            let
                ( model, cmds ) =
                    AuthRedirectPage.init context params
            in
            ( AuthRedirect model, Cmd.map GotAuthGithubRedirectMsg cmds )


toContext : Model -> Context
toContext model =
    case model of
        Example m ->
            m.context

        Home m ->
            m.context

        NotFound context ->
            context

        AuthRedirect m ->
            m.context


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
        Example examplesModel ->
            viewPage
                (Page.Examples
                    examplesModel.author
                    examplesModel.package
                    examplesModel.context.session
                    ExamplePage.toHeaderMsg
                    examplesModel.headerState
                )
                GotExampleMsg
                (ExamplePage.view examplesModel)

        Home _ ->
            viewPage Page.Home GotHomeMsg HomePage.view

        AuthRedirect m ->
            viewPage Page.AuthGithubRedirect GotAuthGithubRedirectMsg (AuthRedirectPage.view m)

        NotFound _ ->
            NotFoundPage.view


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( GotExampleMsg examplesMsg, Example examples ) ->
            ExamplePage.update examplesMsg examples
                |> updateWithEffect Example GotExampleMsg exampleEffectHandler

        ( GotAuthGithubRedirectMsg authRedirectMsg, AuthRedirect m ) ->
            let
                ( updatedModel, cmds ) =
                    AuthRedirectPage.update m authRedirectMsg
            in
            ( AuthRedirect updatedModel, Cmd.map GotAuthGithubRedirectMsg cmds )

        ( ClickedLink urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl (Context.navKey <| toContext model) (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        ( ChangedUrl url, _ ) ->
            changeRouteTo (Route.fromUrl url) (toContext model)

        ( RefreshedSession result, Example m ) ->
            let
                updatedModel =
                    { m | context = Context.updateSession updatedSession m.context }

                ( sessionCmd, updatedSession ) =
                    Session.fromResult result
            in
            ( Example updatedModel, sessionCmd )

        ( SessionAuthorizing result, Example m ) ->
            let
                updatedModel =
                    { m | context = Context.updateSession updatedSession m.context }

                ( sessionCmd, updatedSession ) =
                    Session.fromResult result
            in
            ( Example updatedModel, sessionCmd )

        ( SessionDestroying result, Example m ) ->
            let
                updatedModel =
                    { m | context = Context.updateSession updatedSession m.context }

                ( sessionCmd, updatedSession ) =
                    Session.fromResult result
            in
            ( Example updatedModel, sessionCmd )

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
subscriptions model =
    case model of
        AuthRedirect _ ->
            Sub.map GotAuthGithubRedirectMsg AuthRedirectPage.subscriptions

        Example m ->
            Sub.map GotExampleMsg (ExamplePage.subscriptions m)

        _ ->
            Sub.none


exampleEffectHandler : Effect.Handler ExamplePage.Model ExamplePage.Effect Msg
exampleEffectHandler model effect =
    case effect of
        ExamplePage.HeaderEffect headerEffect ->
            headerEffectHandler model headerEffect


headerEffectHandler : Effect.Handler ExamplePage.Model Header.HeaderEffect Msg
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
            let
                viewer =
                    Session.getViewer model.context.session

                ( sessionCmd, session ) =
                    case viewer of
                        Just v ->
                            Session.logOut SessionDestroying (Viewer.credentials v)

                        _ ->
                            ( Cmd.none, model.context.session )

                updatedContext =
                    Context.updateSession session model.context
            in
            ( { model | context = updatedContext }, sessionCmd )


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
