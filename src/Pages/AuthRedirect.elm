module Pages.AuthRedirect exposing (Model, Msg, init, subscriptions, update, view)

import Components.ExhibitPane as ExhibitPane
import Components.Paragraph as Paragraph
import Context exposing (Context)
import Css
import GithubAuth as GithubAuth
import Header
import Html.Styled as Styled exposing (Attribute, div, text)
import Html.Styled.Attributes as StyledAttribs
import Pages.Interstitial.Interstitial as Interstitial
import Ports exposing (decodeRefererFromStateParam)
import Styles.Color exposing (exColorColt100)
import Styles.Grid as Grid


type Msg
    = DecodedRefererString String


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
        cmds =
            case maybeAuthParams of
                Just authParams ->
                    decodeRefererFromStateParam (GithubAuth.stateStringFromParams authParams)

                _ ->
                    Cmd.none
    in
    ( { context = context, authParams = maybeAuthParams, referer = Nothing }, cmds )


paneView : Model -> Styled.Html msg
paneView model =
    paneWrapper
        [ pane
            [ ExhibitPane.view ExhibitPane.default
                [ Interstitial.view
                    (Interstitial.signingIn
                        |> Interstitial.content
                            (paneContent model)
                    )
                ]
            ]
        ]


paneContent : Model -> List (Styled.Html msg)
paneContent model =
    let
        resolvedReferer =
            case model.referer of
                Just referer ->
                    Paragraph.view (Paragraph.default |> Paragraph.style Paragraph.Body) [ text <| GithubAuth.refererToString referer ]

                _ ->
                    text "where you tried to log in from."
    in
    [ div [ StyledAttribs.css [ Css.width (Css.pct 75) ] ]
        [ Paragraph.view
            (Paragraph.default
                |> Paragraph.style Paragraph.Intro
            )
            [ text "After we sign you in we will redirect you back to ", resolvedReferer ]
        , Paragraph.view (Paragraph.default |> Paragraph.style Paragraph.Intro) [ text "Please don't navigate away from this page in the mean time." ]
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
            ( { model | referer = Just <| GithubAuth.toReferer decodedReferer }, Cmd.none ) |> Debug.log decodedReferer


subscriptions : Sub Msg
subscriptions =
    Ports.decodedRefererFromStateParam DecodedRefererString
