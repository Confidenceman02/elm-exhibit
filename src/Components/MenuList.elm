module Components.MenuList exposing
    ( Msg
    , State
    , action
    , default
    , initialState
    , navigation
    , section
    , sections
    , show
    , state
    , subscriptions
    , update
    , view
    , zIndex
    )

import Browser.Events as BrowserEvents
import Components.DummyInput as DummyInput
import Css
import Html.Styled as Styled exposing (a, div, text)
import Html.Styled.Attributes as StyledAttribs
import Html.Styled.Events as Events
import List.Extra as ListX
import Time


type Config item
    = Config (Configuration item)


type State
    = State_ StateData



-- CONSTANTS


menuListItemSuffix : String
menuListItemSuffix =
    "menu-list-item"


dummyInputSuffix : String
dummyInputSuffix =
    "menu-list-dummy-input"


type alias SectionPosition =
    Int


type alias ItemPosition =
    Int



-- STATE


type FocusedListItem
    = FocusedListItem SectionPosition ItemPosition


type alias StateData =
    { step : Step
    , focusedListItem : Maybe FocusedListItem
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
    State_ { step = Invisible, focusedListItem = Nothing }



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


type alias Styling =
    { hoverStyles : HoverFocusStyles
    , focusStyles : HoverFocusStyles
    }


type HoverFocusStyles
    = Styled ItemStyles
    | UnStyled


type alias ItemStyles =
    { backgroundColor : Css.Color
    , color : Css.Color
    }


type alias Configuration item =
    { sections : List (Section item)
    , zIndex : Int
    , state : State
    , styling : Styling
    }


defaults : Configuration item
defaults =
    { sections = []
    , zIndex = 0
    , state = initialState
    , styling =
        { hoverStyles = Styled { backgroundColor = Css.hex "#5FABDC", color = Css.hex "#FFFFFF" }
        , focusStyles = Styled { backgroundColor = Css.hex "#5FABDC", color = Css.hex "#FFFFFF" }
        }
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
    | MakeVisible Time.Posix
    | ListItemFocused Int Int


subscriptions : State -> Sub Msg
subscriptions (State_ s) =
    case s.step of
        BecomingVisible Triggered ->
            -- We are not worrying about animation at the moment, just make visible
            BrowserEvents.onAnimationFrame MakeVisible

        BecomingInvisible Triggered ->
            Sub.none

        _ ->
            Sub.none


update : Msg -> State -> ( State, Cmd Msg )
update msg ((State_ state_) as s) =
    case msg of
        MakeVisible _ ->
            ( State_ { state_ | step = Visible }, Cmd.none )

        ListItemFocused sectionIndex itemIndex ->
            ( s, Cmd.none )

        None ->
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
                    , Css.backgroundColor (Css.hex "#FFFFFF")
                    , Css.zIndex (Css.int config.zIndex)
                    , Css.borderRadius (Css.px 6)
                    , Css.border3 (Css.px 1) Css.solid (Css.hex "#FFFFFF")
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
    ListX.indexedFoldr (renderSection config.styling) [] config.sections


renderSection : Styling -> Int -> Section item -> List (Styled.Html Msg) -> List (Styled.Html Msg)
renderSection styling sectionIndex (Section menuItems) accumViews =
    let
        buildView item itemIndex =
            case item of
                Navigation config ->
                    a
                        [ StyledAttribs.href config.href
                        , StyledAttribs.id (buildItemId sectionIndex itemIndex)
                        , StyledAttribs.css (listItemContainerStyles ++ listItemFocusHoverStyles styling ++ navigationListItemStyles)
                        , StyledAttribs.tabindex 0
                        , Events.onFocus (ListItemFocused sectionIndex itemIndex)
                        ]
                        [ text config.label ]

                Action config ->
                    div
                        [ StyledAttribs.css (listItemContainerStyles ++ listItemFocusHoverStyles styling ++ pointerStyles ++ listItemFocusWithinStyles styling)
                        , StyledAttribs.id (buildItemId sectionIndex itemIndex)
                        ]
                        [ Styled.fromUnstyled <| DummyInput.view DummyInput.default (buildDummyInputId sectionIndex itemIndex)
                        , text config.label
                        ]

                CustomNavigation href configs ->
                    a [ StyledAttribs.href href, StyledAttribs.css (listItemContainerStyles ++ listItemFocusHoverStyles styling ++ pointerStyles) ] <| List.map renderBaseConfiguration configs

                CustomAction configs ->
                    div [ StyledAttribs.css (listItemContainerStyles ++ listItemFocusHoverStyles styling ++ pointerStyles) ] <| List.map renderCustomAction configs

                Custom configs ->
                    div [ StyledAttribs.css (listItemContainerStyles ++ listItemFocusHoverStyles styling ++ pointerStyles) ] <| List.map renderBaseConfiguration configs

        buildViews items builtViews itemCount =
            case items of
                [] ->
                    builtViews

                head :: [] ->
                    builtViews ++ [ buildView head itemCount ]

                headItem :: tailItems ->
                    buildViews tailItems (builtViews ++ [ buildView headItem itemCount ]) (itemCount + 1)
    in
    buildViews menuItems accumViews 0


renderBaseConfiguration : BaseConfiguration -> Styled.Html Msg
renderBaseConfiguration customNavConfig =
    Styled.node customNavConfig.tag [ StyledAttribs.css customNavConfig.styles ] [ text customNavConfig.content ]


renderCustomAction : CustomActionConfiguration item BaseConfiguration -> Styled.Html Msg
renderCustomAction customActionConfig =
    Styled.node customActionConfig.tag [ StyledAttribs.css customActionConfig.styles ] [ text customActionConfig.content ]



-- HELPERS


show : State -> State
show (State_ s) =
    State_ { s | step = BecomingVisible Triggered }


buildItemId : Int -> Int -> String
buildItemId sectionIndex itemIndex =
    "S" ++ String.fromInt sectionIndex ++ "I" ++ String.fromInt itemIndex ++ "-" ++ menuListItemSuffix


buildDummyInputId : Int -> Int -> String
buildDummyInputId sectionIndex itemIndex =
    "S" ++ String.fromInt sectionIndex ++ "I" ++ String.fromInt itemIndex ++ "-" ++ dummyInputSuffix



-- STYLES


listItemContainerStyles : List Css.Style
listItemContainerStyles =
    [ Css.padding4 (Css.px 4) (Css.px 8) (Css.px 4) (Css.px 16)
    , Css.whiteSpace Css.noWrap
    , Css.textOverflow Css.ellipsis
    , Css.overflow Css.hidden
    , Css.display Css.block
    , Css.position Css.relative
    ]


pointerStyles : List Css.Style
pointerStyles =
    [ Css.cursor Css.pointer
    ]


navigationListItemStyles : List Css.Style
navigationListItemStyles =
    [ Css.outline Css.none
    , Css.textDecoration Css.none
    ]


resolveFocusHoverStyles : HoverFocusStyles -> List Css.Style
resolveFocusHoverStyles hoverFocusStyles =
    case hoverFocusStyles of
        Styled itemStyles ->
            [ Css.backgroundColor itemStyles.backgroundColor
            , Css.color itemStyles.color
            ]

        _ ->
            []


listItemFocusHoverStyles : Styling -> List Css.Style
listItemFocusHoverStyles styling =
    let
        hoverStyling =
            styling.hoverStyles

        focusStyling =
            styling.focusStyles
    in
    [ Css.hover (resolveFocusHoverStyles hoverStyling)
    , Css.focus (resolveFocusHoverStyles focusStyling)
    ]


listItemFocusWithinStyles : Styling -> List Css.Style
listItemFocusWithinStyles styling =
    [ Css.pseudoClass "focus-within" (resolveFocusHoverStyles styling.focusStyles) ]
