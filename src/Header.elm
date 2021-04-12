module Header exposing
    ( Config
    , HeaderEffect(..)
    , Msg
    , State
    , author
    , exhibit
    , initState
    , navBottomBorder
    , navHeight
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
import Components.Indicator as Indicator
import Components.Link as Link
import Css as Css
import DummyInput
import Effect exposing (Effect)
import EventsExtra
import Html.Styled as Styled exposing (div, h1, img, span, text)
import Html.Styled.Attributes as StyledAttribs
import Html.Styled.Events as Events
import Html.Styled.Extra exposing (viewIf)
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
    = Exhibit Author Package
    | Author Author
    | Home


type Msg
    = SignIn
    | SignOut
    | MenuTriggerFocused
    | MenuTriggerBlurred
    | ToggleMenu
    | ShowMenuAndFocusFirst
    | ShowMenuAndFocusLast
    | MenuFocusFirst
    | MenuFocusLast
    | HideMenu
    | MenuListMsg (MenuList.Msg MenuListAction)


type MenuListAction
    = SignOutAction


type State
    = State State_


type alias State_ =
    { menu : Menu
    , menuListState : Session -> MenuList.State MenuListAction
    }


type Menu
    = Idle
    | TriggerFocused


type alias Configuration =
    { variant : Variant
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
    , state = initState
    }


type HeaderEffect
    = SignInEffect
    | SignOutEffect



-- CONFIG BUILDERS


exhibit : Author -> Package -> Config
exhibit authr package =
    Config { defaultConfig | variant = Exhibit authr package }


author : Author -> Config
author authr =
    Config { defaultConfig | variant = Author authr }


state : State -> Config -> Config
state s (Config config) =
    Config { config | state = s }


view : Config -> Session -> Styled.Html Msg
view (Config config) session =
    div
        [ StyledAttribs.css
            [ Css.width <| Css.calc (Css.pct 100) Css.minus (Css.px 40)
            , Css.paddingLeft (Css.px 20)
            , Css.paddingRight (Css.px 20)
            , Css.backgroundColor exColorSky600
            , Css.overflowX Css.hidden
            , Css.borderBottom3 (Css.px navBottomBorder) Css.solid exColorSky700
            , Css.height (Css.px navHeight)
            , Css.position Css.relative
            , Css.overflow Css.visible
            ]
        ]
        [ homeLink
        , div [ StyledAttribs.css absoluteCenterHorizontal ]
            [ nav config
            ]
        , sessionActionView config.state session
        ]


sessionActionView : State -> Session -> Styled.Html Msg
sessionActionView (State state_) sesh =
    let
        resolveText =
            if Session.isGuest sesh || Session.isLoggingIn sesh then
                span [ StyledAttribs.css [ Css.color exColorWhite, Css.marginRight Grid.halfGrid ] ]
                    [ Heading.view (Heading.h5 |> Heading.inline True)
                        (case sesh of
                            Session.Guest ->
                                "Continue with Github"

                            Session.LoggingIn ->
                                "Logging in"

                            Session.Failed ->
                                "Continue with Github"

                            _ ->
                                ""
                        )
                    ]

            else
                text ""

        withSessionAction config =
            case sesh of
                Session.LoggedIn _ ->
                    Button.onClick SignOut config

                Session.Guest ->
                    Button.onClick SignIn config

                Session.Failed ->
                    Button.onClick SignIn config

                _ ->
                    config

        menuListShowing =
            MenuList.isShowing (state_.menuListState sesh)
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
                    let
                        arrowKeyMessages =
                            if menuListShowing then
                                [ EventsExtra.isDownArrow MenuFocusFirst
                                , EventsExtra.isUpArrow MenuFocusLast
                                ]

                            else
                                [ EventsExtra.isDownArrow ShowMenuAndFocusFirst
                                , EventsExtra.isUpArrow ShowMenuAndFocusLast
                                ]
                    in
                    menuListContainer state_
                        sesh
                        [ Styled.fromUnstyled <|
                            DummyInput.view
                                (DummyInput.default
                                    |> DummyInput.onFocus MenuTriggerFocused
                                    |> DummyInput.onBlur MenuTriggerBlurred
                                    |> DummyInput.preventKeydownOn
                                        ([ EventsExtra.isEnter ToggleMenu
                                         , EventsExtra.isSpace ToggleMenu
                                         , EventsExtra.isEscape HideMenu
                                         ]
                                            ++ arrowKeyMessages
                                        )
                                )
                                menuListTriggerId
                        , viewerAvatar menuListShowing viewer
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
                                        |> MenuList.state (state_.menuListState sesh)
                                    )
                                )
                            ]
                        ]

                Session.LoggingOut viewer ->
                    menuListContainer state_ sesh [ viewerAvatar menuListShowing viewer ]

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
                    withBeforeElement state_ sesh ++ focusTriggerStyles state_

                _ ->
                    []
    in
    div
        [ StyledAttribs.css
            ([ Css.displayFlex
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


withBeforeElement : State_ -> Session -> List Css.Style
withBeforeElement state_ sesh =
    if MenuList.isShowing (state_.menuListState sesh) then
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


viewerAvatar : Bool -> Viewer -> Styled.Html msg
viewerAvatar menuShowing viewer =
    let
        resolveIndicatorOrientation =
            if menuShowing then
                Indicator.UpFacing

            else
                Indicator.DownFacing
    in
    div
        [ StyledAttribs.css
            [ Css.displayFlex
            , Css.alignItems Css.center
            ]
        ]
        [ img
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
        , span
            [ StyledAttribs.css
                [ Css.marginLeft (Grid.calc Grid.halfGrid Grid.divide 2)
                , Css.color exColorWhite
                ]
            ]
            [ Indicator.view resolveIndicatorOrientation ]
        ]


nav : Configuration -> Styled.Html msg
nav config =
    div
        [ StyledAttribs.css
            [ Css.color exColorWhite
            , Css.displayFlex
            , Css.alignItems Css.center
            ]
        ]
        [ case config.variant of
            Exhibit authr package ->
                exhibitTitle authr package

            Author authr ->
                authorTitle authr

            _ ->
                text ""
        ]


homeLink : Styled.Html msg
homeLink =
    div
        [ StyledAttribs.css
            [ Css.transform (Css.translate2 (Css.pct 0) (Css.pct -50))
            , Css.position Css.absolute
            , Css.top (Css.pct 50)
            , Css.color exColorWhite
            ]
        ]
        [ Link.view (Link.default |> Link.href "/")
            (Link.htmlBody
                [ div [ StyledAttribs.css [ Css.displayFlex, Css.alignItems Css.center ] ]
                    [ ElmLogo.view <| ElmLogo.static
                    , appTitle
                    ]
                ]
            )
        ]


exhibitTitle : Author -> Package -> Styled.Html msg
exhibitTitle authr package =
    h1 [ StyledAttribs.css [ Css.fontWeight (Css.int 400) ] ]
        [ text (Author.toString authr)
        , span [ StyledAttribs.css [ Css.margin2 (Css.px 0) (Css.px 10) ] ] [ text "/" ]
        , text (Package.toString package)
        ]


authorTitle : Author -> Styled.Html msg
authorTitle authr =
    h1 [ StyledAttribs.css [ Css.fontWeight (Css.int 400) ] ]
        [ text (Author.toString authr)
        ]


appTitle : Styled.Html msg
appTitle =
    div [ StyledAttribs.css [ Css.paddingLeft (Css.px 8) ] ]
        [ div [ StyledAttribs.css [ Css.lineHeight (Css.px 24), Css.fontSize (Css.px 28) ] ] [ text "elm" ]
        , div [ StyledAttribs.css [ Css.fontSize (Css.px 16) ] ] [ text "exhibit" ]
        ]



-- STATE


initState : State
initState =
    State
        { menu = Idle
        , menuListState =
            \latestSession ->
                MenuList.initialState
                    |> MenuList.sections
                        (resolveSections
                            latestSession
                        )
        }


newMenuListState : MenuList.State MenuListAction -> Session -> MenuList.State MenuListAction
newMenuListState latestState =
    \latestSession ->
        latestState
            |> MenuList.sections (resolveSections latestSession)


resolveSections : Session -> List (MenuList.Section MenuListAction)
resolveSections sesh =
    case sesh of
        Session.LoggedIn viewer ->
            [ MenuList.section
                [ MenuList.navigation { label = "Home", href = "/" }
                , MenuList.navigation { label = "Your exhibits", href = "/" ++ Viewer.getUsername viewer }
                ]
            , MenuList.section
                [ MenuList.action { label = "Sign out", item = SignOutAction }
                ]
            ]

        _ ->
            []



-- UPDATE


subscriptions : State -> Session -> Sub Msg
subscriptions (State state_) sesh =
    Sub.map MenuListMsg (MenuList.subscriptions (state_.menuListState sesh))


update : Session -> State -> Msg -> ( State, Cmd Msg, Effect HeaderEffect )
update sesh state_ msg =
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
                menuListState =
                    if MenuList.isShowing (s.menuListState sesh) then
                        MenuList.hide (s.menuListState sesh)

                    else
                        MenuList.show (s.menuListState sesh)
            in
            ( State { s | menuListState = newMenuListState menuListState }, Cmd.none, Effect.none )

        ShowMenuAndFocusFirst ->
            let
                menuListState =
                    MenuList.showAndFocusFirst (s.menuListState sesh)
                        |> MenuList.setReturnFocusTarget (MenuList.returnFocusId (DummyInput.inputIdPrefix ++ menuListTriggerId))
            in
            ( State { s | menuListState = newMenuListState menuListState }, Cmd.none, Effect.none )

        ShowMenuAndFocusLast ->
            let
                menuListState =
                    MenuList.showAndFocusLast (s.menuListState sesh)
                        |> MenuList.setReturnFocusTarget (MenuList.returnFocusId (DummyInput.inputIdPrefix ++ menuListTriggerId))
            in
            ( State { s | menuListState = newMenuListState menuListState }, Cmd.none, Effect.none )

        MenuFocusFirst ->
            let
                menuListState =
                    MenuList.focusFirst (s.menuListState sesh)
            in
            ( State { s | menuListState = newMenuListState menuListState }, Cmd.none, Effect.none )

        MenuFocusLast ->
            let
                menuListState =
                    MenuList.focusLast (s.menuListState sesh)
            in
            ( State { s | menuListState = newMenuListState menuListState }, Cmd.none, Effect.none )

        HideMenu ->
            let
                menuListState =
                    MenuList.hide (s.menuListState sesh)
            in
            ( State { s | menuListState = newMenuListState menuListState }, Cmd.none, Effect.none )

        MenuListMsg menuListMsg ->
            let
                ( menuListState, menuListCmd, menuListAction ) =
                    MenuList.update menuListMsg (s.menuListState sesh)

                effect =
                    case menuListAction of
                        Just (ActionItemClicked SignOutAction) ->
                            Effect.single SignOutEffect

                        Nothing ->
                            Effect.none
            in
            ( State { s | menuListState = newMenuListState menuListState }, Cmd.map MenuListMsg menuListCmd, effect )
