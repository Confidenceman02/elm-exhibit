module Header exposing
    ( Config
    , HeaderEffect(..)
    , Msg
    , State
    , example
    , home
    , initState
    , navBottomBorder
    , navHeight
    , session
    , state
    , subscriptions
    , update
    , view
    )

import Author exposing (Author)
import Components.Button as Button
import Components.ElmLogo as ElmLogo
import Components.GithubLogo as GithubLogo
import Components.Heading as Heading
import Components.Link as Link
import Css as Css
import DummyInput
import Effect exposing (Effect)
import EventsExtra
import Html.Styled as Styled exposing (div, h1, img, span, text)
import Html.Styled.Attributes as StyledAttribs
import Html.Styled.Events as Events
import Html.Styled.Extra exposing (viewIf, viewMaybe)
import MenuList.MenuList as MenuList exposing (Actions(..))
import Package exposing (Package)
import Session exposing (Session)
import Styles.Color exposing (exColorSky600, exColorSky700, exColorWhite)
import Styles.Common exposing (absoluteCenterHorizontal)
import Styles.Grid as Grid
import Viewer exposing (Viewer)


navHeight : Float
navHeight =
    64


navBottomBorder : Float
navBottomBorder =
    2


avatarHeight : Float
avatarHeight =
    33


menuListTriggerId : String
menuListTriggerId =
    "headerMenuListTrigger"


type Config
    = Config Configuration


type Variant
    = Example Author Package
    | Home


type Msg
    = SignIn
    | SignOut
    | MenuTriggerFocused
    | MenuTriggerBlurred
    | ToggleMenu
    | HideMenu
    | MenuListMsg (MenuList.Msg MenuListAction)


type MenuListAction
    = SignOutAction


type State
    = State State_


type alias State_ =
    { menu : Menu
    , menuListState : MenuList.State MenuListAction
    }


type Menu
    = Idle
    | TriggerFocused


type alias Configuration =
    { variant : Variant
    , session : Maybe Session
    , state : State
    }


type alias PackageConfiguration =
    { owner : String
    , repo : String
    , version : String
    }


defaultConfig : Configuration
defaultConfig =
    { variant = Home
    , session = Nothing
    , state = initState
    }


type HeaderEffect
    = SignInEffect
    | SignOutEffect



-- CONFIG BUILDERS


example : Author -> Package -> Config
example author package =
    Config { defaultConfig | variant = Example author package }


session : Session -> Config -> Config
session sesh (Config config) =
    Config { config | session = Just sesh }


home : Config
home =
    Config { defaultConfig | variant = Home }


state : State -> Config -> Config
state s (Config config) =
    Config { config | state = s }


view : Config -> Styled.Html Msg
view (Config config) =
    div
        [ StyledAttribs.css
            [ Css.width <| Css.calc (Css.pct 100) Css.minus (Css.px 40)
            , Css.paddingLeft (Css.px 20)
            , Css.paddingRight (Css.px 20)
            , Css.backgroundColor exColorSky600
            , Css.overflowX Css.hidden
            , Css.borderBottom3 (Css.px navBottomBorder) Css.solid exColorSky700
            , Css.height (Css.px navHeight)
            ]
        ]
        [ div [ StyledAttribs.css absoluteCenterHorizontal ]
            [ nav config
            ]
        , viewMaybe (sessionActionView config.state) config.session
        ]


sessionActionView : State -> Session -> Styled.Html Msg
sessionActionView (State state_) sesh =
    let
        resolveText =
            if Session.isGuest sesh || Session.isLoggingIn sesh then
                span [ StyledAttribs.css [ Css.color exColorWhite, Css.marginRight Grid.halfGrid ] ]
                    [ Heading.view (Heading.h5 |> Heading.inline True)
                        (if Session.isGuest sesh then
                            "Log in with Github"

                         else if Session.isLoggingIn sesh then
                            "Logging in"

                         else
                            ""
                        )
                    ]

            else
                text ""

        withSessionAction config =
            if Session.isLoggedIn sesh then
                Button.onClick SignOut config

            else if Session.isGuest sesh then
                Button.onClick SignIn config

            else
                config
    in
    viewIf
        ((not <| Session.isRefreshing sesh)
            && (not <| Session.isIdle sesh)
        )
        (div
            [ StyledAttribs.css
                [ Css.top (Css.px 0)
                , Css.right (Css.px 2)
                , Css.height (Css.px navHeight)
                , Css.displayFlex
                , Css.alignItems Css.center
                , Css.marginRight Grid.halfGrid
                , Css.position Css.absolute
                ]
            ]
            [ case sesh of
                Session.LoggedIn viewer ->
                    menuListContainer state_
                        sesh
                        [ Styled.fromUnstyled <|
                            DummyInput.view
                                (DummyInput.default
                                    |> DummyInput.onFocus MenuTriggerFocused
                                    |> DummyInput.onBlur MenuTriggerBlurred
                                    |> DummyInput.preventKeydownOn
                                        [ EventsExtra.isEnter ToggleMenu
                                        , EventsExtra.isSpace ToggleMenu
                                        , EventsExtra.isEscape HideMenu

                                        --, EventsExtra.isDownArrow ToggleMenu
                                        ]
                                )
                                menuListTriggerId
                        , viewerAvatar viewer
                        , span
                            [ StyledAttribs.css
                                [ Css.position Css.absolute
                                , Css.right (Css.px 0)
                                , Css.top (Css.px avatarHeight)
                                , Css.zIndex (Css.int 100)
                                , Css.marginTop Grid.halfGrid
                                ]
                            ]
                            [ Styled.map MenuListMsg
                                (MenuList.view
                                    (MenuList.default
                                        |> MenuList.state state_.menuListState
                                    )
                                )
                            ]
                        ]

                Session.LoggingOut viewer ->
                    menuListContainer state_ sesh [ viewerAvatar viewer ]

                _ ->
                    Button.view
                        (Button.wrapper
                            [ span [ StyledAttribs.css [ Css.alignItems Css.center, Css.displayFlex ] ]
                                [ resolveText
                                , GithubLogo.view GithubLogo.default
                                ]
                            ]
                            |> withSessionAction
                        )
                        ""
            ]
        )


menuListContainer : State_ -> Session -> List (Styled.Html Msg) -> Styled.Html Msg
menuListContainer state_ sesh content =
    let
        withAddedStyles =
            case sesh of
                Session.LoggedIn _ ->
                    withBeforeElement state_ ++ focusTriggerStyles state_

                _ ->
                    []
    in
    div
        [ StyledAttribs.css
            ([ Css.displayFlex
             , Css.marginRight Grid.halfGrid
             , Css.position Css.relative
             , Css.cursor Css.pointer
             ]
                ++ withAddedStyles
            )
        , Events.onClick ToggleMenu
        ]
        content


focusTriggerStyles : State_ -> List Css.Style
focusTriggerStyles state_ =
    case state_.menu of
        TriggerFocused ->
            [ Css.outline3 (Css.px 1) Css.solid exColorWhite ]

        _ ->
            []


withBeforeElement : State_ -> List Css.Style
withBeforeElement state_ =
    if MenuList.isShowing state_.menuListState then
        [ Css.before
            [ Css.position Css.fixed
            , Css.top (Css.px 0)
            , Css.right (Css.px 0)
            , Css.bottom (Css.px 0)
            , Css.left (Css.px 0)
            , Css.zIndex (Css.int 80)
            , Css.display Css.block
            , Css.cursor Css.default
            , Css.property "content" "' '"
            , Css.property "background" "transparent"
            ]
        ]

    else
        []


viewerAvatar : Viewer -> Styled.Html msg
viewerAvatar viewer =
    img
        [ StyledAttribs.alt (Viewer.getUsername viewer)
        , StyledAttribs.css
            [ Css.borderRadius (Css.px 17)
            , Css.height (Css.px avatarHeight)
            , Css.width (Css.px 33)
            , Css.border3 (Css.px 1) Css.solid exColorSky700
            ]
        , StyledAttribs.src (Viewer.getAvatarUrl viewer)
        ]
        []


nav : Configuration -> Styled.Html msg
nav config =
    div
        [ StyledAttribs.css
            [ Css.color exColorWhite
            , Css.displayFlex
            , Css.alignItems Css.center
            ]
        ]
        -- shadowLink is just taking up the space so we can absolutely position the actual home logo link
        [ shadowHomeLink
        , case config.variant of
            Example author package ->
                exampleTitle author package

            _ ->
                text ""
        , homeLink
        ]


homeLink : Styled.Html msg
homeLink =
    div [ StyledAttribs.css [ Css.position Css.absolute ] ]
        [ Link.view (Link.default |> Link.href "/")
            (Link.htmlBody
                [ div [ StyledAttribs.css [ Css.displayFlex, Css.alignItems Css.center ] ]
                    [ ElmLogo.view <| ElmLogo.static
                    , appTitle
                    ]
                ]
            )
        ]


shadowHomeLink : Styled.Html msg
shadowHomeLink =
    div [ StyledAttribs.css [ Css.displayFlex, Css.marginRight (Css.px 32), Css.visibility Css.hidden ] ]
        [ div [ StyledAttribs.css [ Css.displayFlex, Css.alignItems Css.center ] ]
            [ ElmLogo.view <| ElmLogo.static
            , appTitle
            ]
        ]


exampleTitle : Author -> Package -> Styled.Html msg
exampleTitle author package =
    h1 [ StyledAttribs.css [ Css.fontWeight (Css.int 400) ] ]
        [ text (Author.toString author)
        , span [ StyledAttribs.css [ Css.margin2 (Css.px 0) (Css.px 10) ] ] [ text "/" ]
        , text (Package.toString package)
        ]


appTitle : Styled.Html msg
appTitle =
    div [ StyledAttribs.css [ Css.paddingLeft (Css.px 8) ] ]
        [ div [ StyledAttribs.css [ Css.lineHeight (Css.px 24), Css.fontSize (Css.px 28) ] ] [ text "elm" ]
        , div [ StyledAttribs.css [ Css.fontSize (Css.px 16) ] ] [ text "exhibit" ]
        ]



-- HELPERS
-- STATE


initState : State
initState =
    State
        { menu = Idle
        , menuListState =
            MenuList.initialState
                |> MenuList.sections
                    [ MenuList.section
                        [ MenuList.navigation { label = "Home", href = "/" }
                        ]
                    , MenuList.section
                        [ MenuList.action { label = "Sign out", item = SignOutAction }
                        ]
                    ]
        }



-- UPDATE


subscriptions : State -> Sub Msg
subscriptions (State state_) =
    Sub.map MenuListMsg (MenuList.subscriptions state_.menuListState)


update : State -> Msg -> ( State, Cmd Msg, Effect HeaderEffect )
update state_ msg =
    let
        (State s) =
            state_
    in
    case msg of
        SignIn ->
            ( state_, Cmd.none, Effect.single SignInEffect )

        SignOut ->
            ( state_, Cmd.none, Effect.single SignOutEffect )

        MenuTriggerFocused ->
            ( State { s | menu = TriggerFocused }, Cmd.none, Effect.none )

        MenuTriggerBlurred ->
            ( State { s | menu = Idle }, Cmd.none, Effect.none )

        ToggleMenu ->
            let
                menuListAction =
                    if MenuList.isShowing s.menuListState then
                        MenuList.hide s.menuListState

                    else
                        MenuList.show s.menuListState
            in
            ( State { s | menuListState = menuListAction }, Cmd.none, Effect.none )

        HideMenu ->
            ( State { s | menuListState = MenuList.hide s.menuListState }, Cmd.none, Effect.none )

        MenuListMsg menuListMsg ->
            let
                ( menuListState, menuListCmd, menuListAction ) =
                    MenuList.update menuListMsg s.menuListState

                effect =
                    case menuListAction of
                        Just (ActionItemClicked SignOutAction) ->
                            Effect.single SignOutEffect

                        Nothing ->
                            Effect.none
            in
            ( State { s | menuListState = menuListState }, Cmd.map MenuListMsg menuListCmd, effect )
