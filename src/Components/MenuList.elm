module Components.MenuList exposing (Msg, State, action, default, initialState, navigation, section, sections, show, state, view, zIndex)

import Css
import Html.Styled as Styled exposing (a, div, text)
import Html.Styled.Attributes as StyledAttribs
import Styles.Border as Border
import Styles.Color as Color exposing (exColorWhite)


type Config item
    = Config (Configuration item)


type State
    = State_ StateData



-- STATE


type alias StateData =
    { step : Step
    }


type StepLifecycle
    = Triggered
    | Resolving


type Step
    = Visible
    | Invisible
    | BecomingVisible StepLifecycle
    | BecomingInvisible StepLifecycle


initialState : State
initialState =
    State_ { step = Invisible }



-- LIST ITEM


{-|

    Navigation - Will consist of an a tag that changes the url.
    this will not fire Cmd Msg's.

    Action - Does some action and does not change URL.
    The item value will be passed in the Cmd Msg.

    CustomNavigation && CustomAction - Its custom because the view is determined
    by the consumer. Only allows for a very simplistic view.

    update :  msg -> model -> (model, Cmd.msg)
    update msg model =
        case msg of
            MenuItemMsg menuItemMsg ->
                let
                    menuItemAction = MenuItem.update menuItemMsg
                in
                case menuItemAction of
                    ClickedActionMenuItem actionMenuItem ->
                        case actionMenuItem of
                            OpenSidePanel ->
                                -- DO SOMETHING

-}
type ListItem item
    = Navigation NavigationConfiguration
    | Action (ActionConfiguration item)
    | CustomNavigation String (List BaseConfiguration)
    | CustomAction (List (CustomActionConfiguration item BaseConfiguration))
    | Custom (List BaseConfiguration)


type alias BaseConfiguration =
    { tag : String
    , styles : List Css.Style
    , content : String
    }


type alias CustomActionConfiguration item base =
    { base
        | item : item
    }


type alias ActionConfiguration item =
    { label : String
    , item : item
    }


type alias NavigationConfiguration =
    { label : String
    , href : String
    }


navigation : NavigationConfiguration -> ListItem item
navigation navigationItemConfig =
    Navigation navigationItemConfig


action : ActionConfiguration item -> ListItem item
action menuItemConfig =
    Action menuItemConfig



-- SECTION


type Section item
    = Section (List (ListItem item))


type alias ItemStyles =
    { onHoverBackgroundColor : Css.Color
    , onHoverColor : Css.Color
    }


type alias Configuration item =
    { sections : List (Section item)
    , zIndex : Int
    , state : State
    , styles : ItemStyles
    }


defaults : Configuration item
defaults =
    { sections = []
    , zIndex = 0
    , state = initialState
    , styles = { onHoverBackgroundColor = Css.hex "#5FABDC", onHoverColor = Css.hex "#FFFFFF" }
    }


default : Config item
default =
    Config defaults



-- MODIFIERS


sections : List (Section item) -> Config item -> Config item
sections sectionList (Config config) =
    Config { config | sections = sectionList }


section : List (ListItem item) -> Section item
section menuItems =
    Section menuItems


zIndex : Int -> Config item -> Config item
zIndex indx (Config config) =
    Config { config | zIndex = indx }


state : State -> Config item -> Config item
state s (Config config) =
    Config { config | state = s }


type Msg
    = None


subscription : State -> Sub Msg
subscription (State_ s) =
    case s.step of
        BecomingVisible Triggered ->
            Sub.none

        BecomingInvisible Triggered ->
            Sub.none

        _ ->
            Sub.none


update : Msg -> State -> ( State, Cmd Msg )
update msg s =
    ( s, Cmd.none )


view : Config item -> Styled.Html Msg
view (Config config) =
    let
        (State_ s) =
            config.state
    in
    case s.step of
        Visible ->
            div
                [ StyledAttribs.css
                    [ Css.width (Css.px 150)
                    , Css.height (Css.pct 100)
                    , Css.backgroundColor exColorWhite
                    , Css.zIndex (Css.int config.zIndex)
                    , Css.borderRadius (Css.px 6)
                    , Css.border3 (Css.px 1) Css.solid Color.exColorBorder
                    , Css.backgroundClip Css.paddingBox
                    , Css.marginTop (Css.px 2)
                    , Css.paddingBottom (Css.px 4)
                    , Css.paddingTop (Css.px 4)
                    ]
                ]
                (renderSections config)

        Invisible ->
            text ""

        _ ->
            text ""


renderSections : Configuration item -> List (Styled.Html Msg)
renderSections config =
    List.foldr (renderSection config.styles) [] config.sections


renderSection : ItemStyles -> Section item -> List (Styled.Html Msg) -> List (Styled.Html Msg)
renderSection itemStyles (Section menuItems) accumViews =
    let
        buildView item =
            case item of
                Navigation config ->
                    a
                        [ StyledAttribs.href config.href
                        , StyledAttribs.css (listItemContainerStyles itemStyles ++ navigationListItemStyles itemStyles)
                        , StyledAttribs.tabindex 0
                        ]
                        [ text config.label ]

                Action config ->
                    div [ StyledAttribs.css (listItemContainerStyles itemStyles ++ pointerStyles) ] [ text config.label ]

                CustomNavigation href configs ->
                    a [ StyledAttribs.href href, StyledAttribs.css (listItemContainerStyles itemStyles ++ pointerStyles) ] <| List.map renderBaseConfiguration configs

                CustomAction configs ->
                    div [ StyledAttribs.css (listItemContainerStyles itemStyles ++ pointerStyles) ] <| List.map renderCustomAction configs

                Custom configs ->
                    div [ StyledAttribs.css (listItemContainerStyles itemStyles ++ pointerStyles) ] <| List.map renderBaseConfiguration configs

        buildViews items builtViews =
            case items of
                [] ->
                    builtViews

                head :: [] ->
                    builtViews ++ [ buildView head ]

                headItem :: tailItems ->
                    buildViews tailItems (builtViews ++ [ buildView headItem ])
    in
    buildViews menuItems accumViews


renderBaseConfiguration : BaseConfiguration -> Styled.Html Msg
renderBaseConfiguration customNavConfig =
    Styled.node customNavConfig.tag [ StyledAttribs.css customNavConfig.styles ] [ text customNavConfig.content ]


renderCustomAction : CustomActionConfiguration item BaseConfiguration -> Styled.Html Msg
renderCustomAction customActionConfig =
    Styled.node customActionConfig.tag [ StyledAttribs.css customActionConfig.styles ] [ text customActionConfig.content ]



-- HELPERS


show : State -> State
show (State_ s) =
    State_ { s | step = Visible }



-- STYLES


listItemContainerStyles : ItemStyles -> List Css.Style
listItemContainerStyles itemStyles =
    [ Css.padding4 (Css.px 4) (Css.px 8) (Css.px 4) (Css.px 16)
    , Css.whiteSpace Css.noWrap
    , Css.textOverflow Css.ellipsis
    , Css.overflow Css.hidden
    , Css.display Css.block
    , Css.position Css.relative
    , Css.hover (listItemFocusHoverStyles itemStyles)
    ]


pointerStyles : List Css.Style
pointerStyles =
    [ Css.cursor Css.pointer
    ]


navigationListItemStyles : ItemStyles -> List Css.Style
navigationListItemStyles itemStyles =
    [ Css.outline Css.none
    , Css.textDecoration Css.none
    , Css.focus (listItemFocusHoverStyles itemStyles)
    ]


listItemFocusHoverStyles : ItemStyles -> List Css.Style
listItemFocusHoverStyles itemStyles =
    [ Css.backgroundColor itemStyles.onHoverBackgroundColor
    , Css.color itemStyles.onHoverColor
    ]
