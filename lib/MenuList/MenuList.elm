module MenuList.MenuList exposing
    ( Actions(..)
    , Msg
    , State
    , action
    , default
    , focusFirst
    , focusLast
    , hide
    , initialState
    , isShowing
    , navigation
    , returnFocusId
    , section
    , sections
    , setReturnFocusTarget
    , show
    , showAndFocusFirst
    , showAndFocusLast
    , state
    , subscriptions
    , update
    , view
    , zIndex
    )

import Browser.Dom as BrowserDom
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
import Task
import Time


type Config item
    = Config (Configuration item)


type State item
    = State_ (StateData item)


type alias SectionIndex =
    Int


type alias ItemIndex =
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
    = FocusedListItem ( SectionIndex, ItemIndex )


type ReturnFocusTarget
    = ReturnFocusTarget String


type alias StateData item =
    { step : Step
    , focusedListItem : Maybe FocusedListItem
    , sections : List (Section item)
    , returnFocusTarget : Maybe ReturnFocusTarget
    }


type VisibleActions
    = FocussingFirstItem
    | FocussingLastItem
    | BecomingInvisible


type InvisibleActions
    = BecomingVisible


type Step
    = Visible (Maybe VisibleActions)
    | Invisible (Maybe InvisibleActions)
    | Batched (List Step)


initialState : State item
initialState =
    State_
        { step = Invisible Nothing
        , returnFocusTarget = Nothing
        , focusedListItem = Nothing
        , sections = []
        }



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
    | DownArrowKeyDowned
    | UpArrowKeyDowned
    | FocusFirstItem Time.Posix
    | FocusLastItem Time.Posix
    | ProcessBatchedSteps Time.Posix


type Actions item
    = ActionItemClicked item


subscriptions : State item -> Sub (Msg item)
subscriptions state_ =
    Sub.batch
        [ stepSubscriptions state_
        , browserEventSubscriptions state_
        ]


browserEventSubscriptions : State item -> Sub (Msg item)
browserEventSubscriptions ((State_ state_) as s) =
    let
        withEscapeKeySub =
            if isShowing s && (state_.focusedListItem == Nothing) then
                BrowserEvents.onKeyDown (EventsExtra.isEscape EscapeKeyDowned)

            else
                Sub.none

        withDownArrowSub =
            if isShowing s && hasFocusedItem s then
                BrowserEvents.onKeyDown (EventsExtra.isDownArrow DownArrowKeyDowned)

            else
                Sub.none

        withUpArrowSub =
            if isShowing s && hasFocusedItem s then
                BrowserEvents.onKeyDown (EventsExtra.isUpArrow UpArrowKeyDowned)

            else
                Sub.none
    in
    Sub.batch [ withEscapeKeySub, withDownArrowSub, withUpArrowSub ]


stepSubscriptions : State item -> Sub (Msg item)
stepSubscriptions (State_ s) =
    case s.step of
        Invisible (Just BecomingVisible) ->
            -- We are not worrying about animation at the moment, just make visible
            BrowserEvents.onAnimationFrame MakeVisible

        Visible (Just BecomingInvisible) ->
            BrowserEvents.onAnimationFrame MakeInvisible

        Visible (Just FocussingFirstItem) ->
            BrowserEvents.onAnimationFrame FocusFirstItem

        Visible (Just FocussingLastItem) ->
            BrowserEvents.onAnimationFrame FocusLastItem

        Batched _ ->
            BrowserEvents.onAnimationFrame ProcessBatchedSteps

        _ ->
            Sub.none


update : Msg item -> State item -> ( State item, Cmd (Msg item), Maybe (Actions item) )
update msg ((State_ state_) as s) =
    case msg of
        MakeVisible _ ->
            ( State_ { state_ | step = Visible Nothing }, Cmd.none, Nothing )

        MakeInvisible _ ->
            ( State_ { state_ | step = Invisible Nothing, focusedListItem = Nothing }, Cmd.none, Nothing )

        ListItemFocused sectionIndex itemIndex ->
            ( State_ { state_ | focusedListItem = Just (FocusedListItem ( sectionIndex, itemIndex )) }, Cmd.none, Nothing )

        EscapeKeyDowned ->
            let
                withReturnFocusTarget =
                    case state_.returnFocusTarget of
                        Just targetId ->
                            Task.attempt (\_ -> None) <| BrowserDom.focus (returnFocusToString targetId)

                        _ ->
                            Cmd.none
            in
            ( State_ { state_ | step = Visible (Just BecomingInvisible) }, withReturnFocusTarget, Nothing )

        DownArrowKeyDowned ->
            case state_.focusedListItem of
                Just (FocusedListItem focusedItemIndices) ->
                    let
                        nextFocusItemIndices =
                            getNextItemPosition focusedItemIndices state_.sections
                    in
                    if focusedItemIndices == nextFocusItemIndices then
                        ( s, Cmd.none, Nothing )

                    else
                        ( s, Task.attempt (\_ -> None) <| BrowserDom.focus (resolveFocusableItemId nextFocusItemIndices state_.sections), Nothing )

                _ ->
                    ( s, Cmd.none, Nothing )

        UpArrowKeyDowned ->
            case state_.focusedListItem of
                Just (FocusedListItem focusedItemIndices) ->
                    let
                        previousFocusItemIndices =
                            getPreviousItemIndices focusedItemIndices state_.sections
                    in
                    if focusedItemIndices == previousFocusItemIndices then
                        ( s, Cmd.none, Nothing )

                    else
                        ( s, Task.attempt (\_ -> None) <| BrowserDom.focus (resolveFocusableItemId previousFocusItemIndices state_.sections), Nothing )

                _ ->
                    ( s, Cmd.none, Nothing )

        ActionItemClicked_ item ->
            ( s, Cmd.none, Just (ActionItemClicked item) )

        FocusFirstItem _ ->
            let
                firstFocusableItemPosition =
                    getFirstItemIndices state_.sections

                focusCmd =
                    case firstFocusableItemPosition of
                        Just firstFocusableIndices ->
                            -- TODO: Check if the focus succeeded
                            Task.attempt (\_ -> None) <| BrowserDom.focus (resolveFocusableItemId firstFocusableIndices state_.sections)

                        _ ->
                            Cmd.none
            in
            ( State_ { state_ | step = Visible Nothing }, focusCmd, Nothing )

        FocusLastItem _ ->
            let
                maybeLastFocusableItemPosition =
                    getLastItemIndices state_.sections

                focusCmd =
                    case maybeLastFocusableItemPosition of
                        Just lastFocusableIndices ->
                            -- TODO: Check if the focus succeeded
                            Task.attempt (\_ -> None) <| BrowserDom.focus (resolveFocusableItemId lastFocusableIndices state_.sections)

                        _ ->
                            Cmd.none
            in
            ( State_ { state_ | step = Visible Nothing }, focusCmd, Nothing )

        -- NOTE: We just want to play through the steps, we are not changing the steps at all.
        -- Theres nothing special going on now but this lets us do time tracking on animations etc.
        ProcessBatchedSteps _ ->
            let
                resolveSteps steps =
                    case steps of
                        [] ->
                            -- TODO: Handle more gracefully.
                            ( State_ { state_ | step = Invisible Nothing }, Cmd.none, Nothing )

                        (Invisible (Just BecomingVisible)) :: [] ->
                            ( State_ { state_ | step = Visible Nothing }, Cmd.none, Nothing )

                        (Invisible Nothing) :: [] ->
                            ( State_ { state_ | step = Invisible Nothing }, Cmd.none, Nothing )

                        (Visible (Just BecomingInvisible)) :: [] ->
                            ( State_ { state_ | step = Invisible Nothing }, Cmd.none, Nothing )

                        (Visible (Just FocussingFirstItem)) :: [] ->
                            let
                                maybeFirstFocusableItemIndices =
                                    getFirstItemIndices state_.sections

                                focusCmd =
                                    case maybeFirstFocusableItemIndices of
                                        Just firstFocusableItemIndices ->
                                            -- TODO: Check if the focus succeeded
                                            Task.attempt (\_ -> None) <| BrowserDom.focus (resolveFocusableItemId firstFocusableItemIndices state_.sections)

                                        _ ->
                                            Cmd.none
                            in
                            ( State_ { state_ | step = Visible Nothing }, focusCmd, Nothing )

                        (Visible (Just FocussingLastItem)) :: [] ->
                            let
                                maybeLastFocusableItemIndices =
                                    getLastItemIndices state_.sections

                                focusCmd =
                                    case maybeLastFocusableItemIndices of
                                        Just lastFocusableItemIndices ->
                                            -- TODO: Check if the focus succeeded
                                            Task.attempt (\_ -> None) <| BrowserDom.focus (resolveFocusableItemId lastFocusableItemIndices state_.sections)

                                        _ ->
                                            Cmd.none
                            in
                            ( State_ { state_ | step = Visible Nothing }, focusCmd, Nothing )

                        (Visible Nothing) :: [] ->
                            ( State_ { state_ | step = Visible Nothing }, Cmd.none, Nothing )

                        (Batched st) :: [] ->
                            ( State_ { state_ | step = Batched st }, Cmd.none, Nothing )

                        (Invisible (Just BecomingVisible)) :: rest ->
                            ( State_ { state_ | step = Batched rest }, Cmd.none, Nothing )

                        (Invisible Nothing) :: rest ->
                            ( State_ { state_ | step = Batched rest }, Cmd.none, Nothing )

                        (Visible (Just BecomingInvisible)) :: rest ->
                            ( State_ { state_ | step = Batched rest }, Cmd.none, Nothing )

                        --TODO: Focus first item.
                        (Visible (Just FocussingFirstItem)) :: rest ->
                            ( State_ { state_ | step = Batched rest }, Cmd.none, Nothing )

                        --TODO: Focus last item.
                        (Visible (Just FocussingLastItem)) :: rest ->
                            ( State_ { state_ | step = Batched rest }, Cmd.none, Nothing )

                        (Visible Nothing) :: rest ->
                            ( State_ { state_ | step = Batched rest }, Cmd.none, Nothing )

                        (Batched st) :: rest ->
                            resolveSteps (st ++ rest)
            in
            case state_.step of
                Batched steps ->
                    resolveSteps steps

                --TODO: Handle non batched steps
                _ ->
                    ( s, Cmd.none, Nothing )

        None ->
            ( s, Cmd.none, Nothing )


view : Config item -> Styled.Html (Msg item)
view (Config config) =
    let
        (State_ s) =
            config.state

        menu =
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
    in
    case s.step of
        Visible _ ->
            menu

        Invisible (Just BecomingVisible) ->
            menu

        Batched batchedSteps ->
            let
                resolveView steps =
                    case steps of
                        [] ->
                            text ""

                        (Visible _) :: _ ->
                            menu

                        (Invisible (Just BecomingVisible)) :: _ ->
                            menu

                        (Invisible Nothing) :: _ ->
                            text ""

                        (Batched st) :: _ ->
                            resolveView st
            in
            resolveView batchedSteps

        Invisible Nothing ->
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
                        , StyledAttribs.id (buildItemId ( sectionIndex, itemIndex ))
                        , StyledAttribs.css (listItemContainerStyles ++ listItemFocusHoverStyles styling ++ navigationListItemStyles)
                        , StyledAttribs.tabindex 0
                        , Events.onFocus (ListItemFocused sectionIndex itemIndex)
                        , Events.preventDefaultOn "keydown"
                            (Decode.map
                                (\m -> ( m, True ))
                                (Decode.oneOf [ EventsExtra.isEscape EscapeKeyDowned ])
                            )
                        ]
                        [ text config.label ]

                Action config ->
                    div
                        [ StyledAttribs.css (listItemContainerStyles ++ listItemFocusHoverStyles styling ++ pointerStyles ++ listItemFocusWithinStyles styling)
                        , StyledAttribs.id (buildItemId ( sectionIndex, itemIndex ))
                        , Events.onClick (ActionItemClicked_ config.item)
                        ]
                        [ Styled.fromUnstyled <|
                            DummyInput.view
                                (DummyInput.default
                                    |> DummyInput.onFocus (ListItemFocused sectionIndex itemIndex)
                                    |> DummyInput.preventKeydownOn [ EventsExtra.isEscape EscapeKeyDowned ]
                                )
                                (buildDummyInputId ( sectionIndex, itemIndex ))
                        , text config.label
                        ]

                CustomNavigation href configs ->
                    a [ StyledAttribs.href href, StyledAttribs.css (listItemContainerStyles ++ listItemFocusHoverStyles styling ++ pointerStyles) ] <| List.map renderBaseConfiguration configs

                CustomAction configs ->
                    div [ StyledAttribs.css (listItemContainerStyles ++ listItemFocusHoverStyles styling ++ pointerStyles) ] <| List.map renderCustomAction configs

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


{-|

    Visibly render the menu list.

    See showAndFocus if you want to show the menu list
    and focus the first focusable item.

-}
show : State item -> State item
show (State_ s) =
    State_ { s | step = Invisible (Just BecomingVisible) }


{-|

        focus the first focusable item in the menu.

        If the menu is not showing nothing will happen. Instead see showAndFocusFirst.

-}
focusFirst : State item -> State item
focusFirst ((State_ state_) as s) =
    case state_.step of
        Visible Nothing ->
            State_ { state_ | step = Visible (Just FocussingFirstItem) }

        _ ->
            s


{-|

        focus the last focusable item in the menu.

        If the menu is not showing nothing will happen. Instead see showAndFocusLast.

-}
focusLast : State item -> State item
focusLast ((State_ state_) as s) =
    case state_.step of
        Visible Nothing ->
            State_ { state_ | step = Visible (Just FocussingLastItem) }

        _ ->
            s


{-|

    Visibly render the menu list and focus the first focusable item.

    If the menu is already open then no items will be focused. Instead see focusFirst.

-}
showAndFocusFirst : State item -> State item
showAndFocusFirst ((State_ state_) as s) =
    case state_.step of
        Visible Nothing ->
            State_ { state_ | step = Visible (Just FocussingFirstItem) }

        (Invisible (Just BecomingVisible)) as currentStep ->
            State_ { state_ | step = Batched [ currentStep, Visible (Just FocussingFirstItem) ] }

        Invisible Nothing ->
            State_ { state_ | step = Batched [ Invisible (Just BecomingVisible), Visible (Just FocussingFirstItem) ] }

        _ ->
            s


{-|

    Visibly render the menu list and focus the last focusable item.

    If the menu is already open then no items will be focused. Instead see focusLast.

-}
showAndFocusLast : State item -> State item
showAndFocusLast ((State_ state_) as s) =
    case state_.step of
        Visible Nothing ->
            State_ { state_ | step = Visible (Just FocussingLastItem) }

        (Invisible (Just BecomingVisible)) as currentStep ->
            State_ { state_ | step = Batched [ currentStep, Visible (Just FocussingLastItem) ] }

        Invisible Nothing ->
            State_ { state_ | step = Batched [ Invisible (Just BecomingVisible), Visible (Just FocussingLastItem) ] }

        _ ->
            s


hide : State item -> State item
hide (State_ s) =
    State_ { s | step = Visible (Just BecomingInvisible) }


{-|

    When the menu is completely visible or is becoming visible.

-}
isShowing : State item -> Bool
isShowing (State_ s) =
    case s.step of
        Visible Nothing ->
            True

        Invisible (Just BecomingVisible) ->
            True

        _ ->
            False



{-
   This assumes the index 0 is always the first item which is not necessarily true.
   What if someone renders this list above a node and the last list item is intended to
   be the first item? e.g.
     __________
     | item 1 |
     | item 2 |
     | item 3 | - first item
     ----------
        NODE

-}


getFirstItemIndices : List (Section item) -> Maybe ( SectionIndex, ItemIndex )
getFirstItemIndices allSections =
    case allSections of
        [] ->
            Nothing

        _ ->
            Just ( 0, 0 )


getLastItemIndices : List (Section item) -> Maybe ( SectionIndex, ItemIndex )
getLastItemIndices allSections =
    let
        lastSectionIndex =
            List.length allSections - 1

        lastItemIndex items =
            List.length items - 1
    in
    case ListX.last allSections of
        Just (Section i) ->
            Just ( lastSectionIndex, lastItemIndex i )

        _ ->
            Nothing


getNextItemPosition : ( SectionIndex, ItemIndex ) -> List (Section item) -> ( SectionIndex, ItemIndex )
getNextItemPosition ( refSectionIndex, refItemIndex ) allSections =
    -- Drop all previous sections
    let
        targetedSections =
            if 0 < refSectionIndex then
                List.drop refSectionIndex allSections

            else
                allSections
    in
    case targetedSections of
        [] ->
            ( refSectionIndex, refItemIndex )

        (Section i) :: [] ->
            if (refItemIndex + 1) < List.length i then
                ( refSectionIndex, refItemIndex + 1 )

            else
                ( 0, 0 )

        (Section i) :: _ ->
            if (refItemIndex + 1) < List.length i then
                ( refSectionIndex, refItemIndex + 1 )

            else
                ( refSectionIndex + 1, 0 )


getPreviousItemIndices : ( SectionIndex, ItemIndex ) -> List (Section item) -> ( SectionIndex, ItemIndex )
getPreviousItemIndices ( refSectionIndex, refItemIndex ) allSections =
    let
        previousSectionIndex =
            refSectionIndex - 1

        lastSectionIndex =
            List.length allSections - 1

        maybeRefSection =
            ListX.getAt refSectionIndex allSections

        maybePreviousAndRefSection =
            ( ListX.getAt previousSectionIndex allSections
            , maybeRefSection
            )

        maybeLastSectionAndRefSection =
            ( ListX.getAt lastSectionIndex allSections
            , maybeRefSection
            )
    in
    -- This means the refSection has sections before it
    if 0 < refSectionIndex then
        case maybePreviousAndRefSection of
            ( Just (Section previousSectionItems), _ ) ->
                -- This means the refItem has items before it
                if 0 < refItemIndex then
                    ( refSectionIndex, refItemIndex - 1 )

                else
                    ( previousSectionIndex, List.length previousSectionItems - 1 )

            _ ->
                -- Shouldn't happen.
                ( refSectionIndex, refItemIndex )

    else if 0 < lastSectionIndex then
        -- refSection is index 0 but there are sections after it.
        case maybeLastSectionAndRefSection of
            ( Just (Section lastSectionItems), _ ) ->
                if 0 < refItemIndex then
                    ( refSectionIndex, refItemIndex - 1 )

                else
                    ( lastSectionIndex, List.length lastSectionItems - 1 )

            _ ->
                -- Shouldn't happen.
                ( refSectionIndex, refItemIndex )

    else
        -- refSection is the only section in the list
        case maybeRefSection of
            Just (Section refSectionItems) ->
                if 0 < refItemIndex then
                    ( refSectionIndex, refItemIndex - 1 )

                else
                    ( refSectionIndex, List.length refSectionItems - 1 )

            _ ->
                -- Shouldn't happen.
                ( refSectionIndex, refItemIndex )


hasFocusedItem : State item -> Bool
hasFocusedItem (State_ state_) =
    case state_.focusedListItem of
        Just _ ->
            True

        _ ->
            False


setReturnFocusTarget : ReturnFocusTarget -> State item -> State item
setReturnFocusTarget focusTarget (State_ state_) =
    State_ { state_ | returnFocusTarget = Just focusTarget }


returnFocusId : String -> ReturnFocusTarget
returnFocusId s =
    ReturnFocusTarget s


returnFocusToString : ReturnFocusTarget -> String
returnFocusToString (ReturnFocusTarget id) =
    id


resolveFocusableItemId : ( SectionIndex, ItemIndex ) -> List (Section item) -> String
resolveFocusableItemId ( sectionIndex, itemIndex ) allSections =
    let
        removedPreviousSections =
            List.drop sectionIndex allSections
    in
    case removedPreviousSections of
        [] ->
            ""

        (Section i) :: _ ->
            case ListX.getAt itemIndex i of
                Just item ->
                    case item of
                        Action _ ->
                            DummyInput.inputIdPrefix ++ buildDummyInputId ( sectionIndex, itemIndex )

                        CustomAction _ ->
                            DummyInput.inputIdPrefix ++ buildDummyInputId ( sectionIndex, itemIndex )

                        Navigation _ ->
                            buildItemId ( sectionIndex, itemIndex )

                        CustomNavigation _ _ ->
                            buildItemId ( sectionIndex, itemIndex )

                _ ->
                    ""


buildItemId : ( SectionIndex, ItemIndex ) -> String
buildItemId ( sectionIndex, itemIndex ) =
    "S" ++ String.fromInt sectionIndex ++ "I" ++ String.fromInt itemIndex ++ "-" ++ menuListItemSuffix


buildDummyInputId : ( SectionIndex, ItemIndex ) -> String
buildDummyInputId ( sectionIndex, itemIndex ) =
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
