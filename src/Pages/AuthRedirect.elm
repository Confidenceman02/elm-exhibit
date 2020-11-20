module Pages.AuthRedirect exposing (Model, Msg, init, subscriptions, update, view)

import Browser.Navigation as Nav
import Components.ExhibitPane as ExhibitPane
import Components.Link as Link
import Components.Paragraph as Paragraph
import Context exposing (Context)
import Css
import GithubAuth as GithubAuth
import Header
import Html.Styled as Styled exposing (Attribute, div, text)
import Html.Styled.Attributes as StyledAttribs
import Pages.Interstitial.Interstitial as Interstitial
import Ports exposing (decodeRefererFromStateParam)
import Session
import Styles.Color exposing (exColorColt100)
import Styles.Grid as Grid
import Url


type Msg
    = DecodedRefererString String
    | SessionLoggedIn (Result Session.SessionError Session.SessionSuccess)


type alias Model =
    { context : Context
    , authParams : Maybe GithubAuth.CallBackParams
    , referer : Maybe GithubAuth.Referer
    }


view : Model -> { title : String, content : Styled.Html msg }
view model =
    { title = "auth redirect", content = pageWrapper [ paneView model ] }


init : Context -> Maybe GithubAuth.CallBackParams -> ( Model, Cmd Msg )
init context maybeAuthParams =
    let
        ( cmds, session ) =
            case maybeAuthParams of
                Just authParams ->
                    let
                        ( sessionCmd, updatedSession ) =
                            Session.callBack SessionLoggedIn authParams
                    in
                    ( Cmd.batch [ decodeRefererFromStateParam (GithubAuth.stateStringFromParams authParams), sessionCmd ], updatedSession )

                _ ->
                    ( Cmd.none, Session.init )
    in
    ( { context = Context.updateSession session context, authParams = maybeAuthParams, referer = Nothing }, cmds )


paneView : Model -> Styled.Html msg
paneView model =
    let
        ( paneContent, interstitialVariant ) =
            if Session.hasFailed model.context.session then
                ( loginFailedContent, Interstitial.bummer )

            else
                ( loggingInPaneContent model, Interstitial.signingIn )
    in
    paneWrapper
        [ pane
            [ ExhibitPane.view ExhibitPane.default
                [ Interstitial.view
                    (interstitialVariant
                        |> Interstitial.content
                            paneContent
                    )
                ]
            ]
        ]


loginFailedContent : List (Styled.Html msg)
loginFailedContent =
    [ div [ StyledAttribs.css [ Css.width (Css.pct 75) ] ]
        [ Paragraph.view
            (Paragraph.default
                |> Paragraph.style Paragraph.Intro
            )
            [ text "We couldn't seem to log you in, please try again later." ]
        ]
    , Link.view (Link.default |> Link.href "/") (Link.stringBody "Back to home")
    ]


loggingInPaneContent : Model -> List (Styled.Html msg)
loggingInPaneContent model =
    let
        resolvedReferer =
            case model.referer of
                Just referer ->
                    Paragraph.view
                        (Paragraph.default
                            |> Paragraph.style Paragraph.BodyBold
                            |> Paragraph.overrides [ Css.overflowWrap Css.breakWord ]
                        )
                        [ text <| GithubAuth.refererToString referer ]

                _ ->
                    text "where you tried to log in from."
    in
    [ div [ StyledAttribs.css [ Css.width (Css.pct 75) ] ]
        [ Paragraph.view
            (Paragraph.default
                |> Paragraph.style Paragraph.Intro
            )
            [ text "After we sign you in we will redirect you back to " ]
        ]
    , resolvedReferer
    , div [ StyledAttribs.css [ Css.width (Css.pct 75) ] ]
        [ Paragraph.view
            (Paragraph.default
                |> Paragraph.style Paragraph.Intro
            )
            [ text "Please don't navigate away from this page in the mean time." ]
        ]
    ]


pane : List (Styled.Html msg) -> Styled.Html msg
pane content =
    div
        [ StyledAttribs.css
            [ Css.position Css.absolute
            , Css.transform (Css.translate2 (Css.pct -50) (Css.pct 0))
            , Css.marginTop (Grid.calc Grid.grid Grid.multiply 1.5)
            , Css.left (Css.pct 50)
            , Css.marginTop (Css.px (Header.navHeight + Header.navBottomBorder))
            ]
        ]
        content


paneWrapper : List (Styled.Html msg) -> Styled.Html msg
paneWrapper content =
    div
        [ StyledAttribs.css
            [ Css.width (Css.pct 100)
            , Css.height (Css.pct 100)
            , Css.backgroundColor exColorColt100
            ]
        ]
        content


pageWrapper : List (Styled.Html msg) -> Styled.Html msg
pageWrapper content =
    div
        [ StyledAttribs.css
            [ Css.top (Css.px 0)
            , Css.bottom (Css.px 0)
            , Css.position Css.fixed
            , Css.width (Css.pct 100)
            ]
        ]
        content


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    case msg of
        DecodedRefererString decodedReferer ->
            let
                referer =
                    case Url.fromString decodedReferer of
                        Just url ->
                            Just (GithubAuth.toReferer url)

                        Nothing ->
                            Nothing
            in
            ( { model | referer = referer }, Cmd.none )

        SessionLoggedIn sessionResult ->
            let
                ( _, session ) =
                    Session.fromResult sessionResult

                redirectCmd =
                    if Session.hasFailed session then
                        Cmd.none

                    else
                        case model.referer of
                            Just referer ->
                                let
                                    refererUrl =
                                        GithubAuth.refererToUrl referer
                                in
                                Nav.pushUrl model.context.navKey refererUrl.path

                            Nothing ->
                                Nav.pushUrl model.context.navKey "/"
            in
            ( { model | context = Context.updateSession session model.context }, redirectCmd )


subscriptions : Sub Msg
subscriptions =
    Ports.decodedRefererFromStateParam DecodedRefererString
