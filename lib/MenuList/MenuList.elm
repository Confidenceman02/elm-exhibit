module MenuList.MenuList exposing
    ( Actions(..)
    , Msg
    , State
    , action
    , default
    , hide
    , initialState
    , isShowing
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
import Css
import DummyInput
import EventsExtra
import Html.Styled as Styled exposing (a, div, text)
import Html.Styled.Attributes as StyledAttribs
import Html.Styled.Events as Events
import Json.Decode as Decode
import List.Extra as ListX
import MenuList.Divider as Divider
import Time


type Config item
    = Config (Configuration item)


type State item
    = State_ (StateData item)


type alias SectionPosition =
    Int


type alias ItemPosition =
    Int



-- CONSTANTS


menuListItemSuffix : String
menuListItemSuffix =
    "menu-list-item"


dummyInputSuffix : String
dummyInputSuffix =
    "menu-list-dummy-input"



-- STATE


type FocusedListItem
    = FocusedListItem SectionPosition ItemPosition


type alias StateData item =
    { step : Step
    , focusedListItem : Maybe FocusedListItem
    , sections : List (Section item)
    }


type StepLifecycle
    = Triggered
    | Resolving


type Step
    = Visible
    | Invisible
    | BecomingVisible StepLifecycle
    | BecomingInvisible StepLifecycle


initialState : State item
initialState =
    State_ { step = Invisible, focusedListItem = Nothing, sections = [] }



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
    { zIndex : Int
    , state : State item
    , styling : Styling
    }


defaults : Configuration item
defaults =
    { zIndex = 0
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


sections : List (Section item) -> State item -> State item
sections sectionList (State_ s) =
    State_ { s | sections = sectionList }


section : List (ListItem item) -> Section item
section menuItems =
    Section menuItems


zIndex : Int -> Config item -> Config item
zIndex indx (Config config) =
    Config { config | zIndex = indx }


state : State item -> Config item -> Config item
state s (Config config) =
    Config { config | state = s }


type Msg item
    = None
    | MakeVisible Time.Posix
    | MakeInvisible Time.Posix
    | ListItemFocused Int Int
    | ActionItemClicked_ item
    | EscapeKeyDowned


type Actions item
    = ActionItemClicked item


subscriptions : State item -> Sub (Msg item)
subscriptions ((State_ s) as state_) =
    Sub.batch
        [ visibilitySubscriptions state_
        , browserEventSubscriptions state_
        ]


browserEventSubscriptions : State item -> Sub (Msg item)
browserEventSubscriptions ((State_ s) as state_) =
    if isShowing state_ && (s.focusedListItem == Nothing) then
        BrowserEvents.onKeyDown (EventsExtra.isEscape EscapeKeyDowned)

    else
        Sub.none


visibilitySubscriptions : State item -> Sub (Msg item)
visibilitySubscriptions (State_ s) =
    case s.step of
        BecomingVisible Triggered ->
            -- We are not worrying about animation at the moment, just make visible
            BrowserEvents.onAnimationFrame MakeVisible

        BecomingInvisible Triggered ->
            BrowserEvents.onAnimationFrame MakeInvisible

        _ ->
            Sub.none


update : Msg item -> State item -> ( State item, Cmd (Msg item), Maybe (Actions item) )
update msg ((State_ state_) as s) =
    case msg of
        MakeVisible _ ->
            ( State_ { state_ | step = Visible }, Cmd.none, Nothing )

        MakeInvisible _ ->
            ( State_ { state_ | step = Invisible, focusedListItem = Nothing }, Cmd.none, Nothing )

        ListItemFocused sectionIndex itemIndex ->
            ( State_ { state_ | focusedListItem = Just (FocusedListItem sectionIndex itemIndex) }, Cmd.none, Nothing )

        EscapeKeyDowned ->
            ( State_ { state_ | step = BecomingInvisible Triggered }, Cmd.none, Nothing )

        ActionItemClicked_ item ->
            ( s, Cmd.none, Just (ActionItemClicked item) )

        None ->
            ( s, Cmd.none, Nothing )


view : Config item -> Styled.Html (Msg item)
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
                    , Css.border3 (Css.px 1) Css.solid (Css.hex "#E6E6E6")
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


renderSections : Configuration item -> List (Styled.Html (Msg item))
renderSections config =
    let
        (State_ s) =
            config.state
    in
    ListX.indexedFoldr (renderSection config.styling (List.length s.sections)) [] s.sections


renderSection : Styling -> Int -> Int -> Section item -> List (Styled.Html (Msg item)) -> List (Styled.Html (Msg item))
renderSection styling sectionCounts sectionIndex (Section menuItems) accumViews =
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
                        , Events.preventDefaultOn "keydown"
                            (Decode.map
                                (\m -> ( m, True ))
                                (EventsExtra.isEscape EscapeKeyDowned)
                            )
                        ]
                        [ text config.label ]

                Action config ->
                    div
                        [ StyledAttribs.css (listItemContainerStyles ++ listItemFocusHoverStyles styling ++ pointerStyles ++ listItemFocusWithinStyles styling)
                        , StyledAttribs.id (buildItemId sectionIndex itemIndex)
                        , Events.onClick (ActionItemClicked_ config.item)
                        ]
                        [ Styled.fromUnstyled <|
                            DummyInput.view
                                (DummyInput.default
                                    |> DummyInput.onFocus (ListItemFocused sectionIndex itemIndex)
                                    |> DummyInput.preventKeydownOn [ EventsExtra.isEscape EscapeKeyDowned ]
                                )
                                (buildDummyInputId sectionIndex itemIndex)
                        , text config.label
                        ]

                CustomNavigation href configs ->
                    a [ StyledAttribs.href href, StyledAttribs.css (listItemContainerStyles ++ listItemFocusHoverStyles styling ++ pointerStyles) ] <| List.map renderBaseConfiguration configs

                CustomAction configs ->
                    div [ StyledAttribs.css (listItemContainerStyles ++ listItemFocusHoverStyles styling ++ pointerStyles) ] <| List.map renderCustomAction configs

                Custom configs ->
                    div [ StyledAttribs.css (listItemContainerStyles ++ listItemFocusHoverStyles styling ++ pointerStyles) ] <| List.map renderBaseConfiguration configs

        buildViews items builtViews itemIndex =
            case items of
                [] ->
                    builtViews

                head :: [] ->
                    builtViews ++ [ buildView head itemIndex ]

                headItem :: tailItems ->
                    buildViews tailItems (builtViews ++ [ buildView headItem itemIndex ]) (itemIndex + 1)

        withDivider =
            if sectionIndex + 1 < sectionCounts then
                [ Divider.view ]

            else
                []
    in
    buildViews menuItems [] 0
        ++ withDivider
        ++ accumViews


renderBaseConfiguration : BaseConfiguration -> Styled.Html (Msg item)
renderBaseConfiguration customNavConfig =
    Styled.node customNavConfig.tag [ StyledAttribs.css customNavConfig.styles ] [ text customNavConfig.content ]


renderCustomAction : CustomActionConfiguration item BaseConfiguration -> Styled.Html (Msg item)
renderCustomAction customActionConfig =
    Styled.node customActionConfig.tag [ StyledAttribs.css customActionConfig.styles ] [ text customActionConfig.content ]



-- HELPERS


show : State item -> State item
show (State_ s) =
    State_ { s | step = BecomingVisible Triggered }


hide : State item -> State item
hide (State_ s) =
    State_ { s | step = BecomingInvisible Triggered }


isShowing : State item -> Bool
isShowing (State_ s) =
    case s.step of
        Visible ->
            True

        BecomingVisible _ ->
            True

        _ ->
            False


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
