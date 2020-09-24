module Pages.Examples exposing (Model, Msg, init, update, view)

import Author exposing (Author)
import Components.Button as Button
import Css as Css
import Header as Header
import Html.Styled as Styled exposing (div, h2, li, p, span, text, ul)
import Html.Styled.Attributes as StyledAttribs
import Package exposing (Package)
import Pages.ExamplesStyles as ExamplesStyles
import Styles.Font as Font
import Styles.Grid as Grid
import Styles.Transition as Transition
import Svg.Styled exposing (polygon, svg)
import Svg.Styled.Attributes exposing (fill, height, points, viewBox)


type alias Model =
    { author : Author
    , package : Package
    , repo : Status Repo
    , descriptionPanel : DescriptionPanel
    , selectedExample : SelectedExample
    }


type DescriptionPanel
    = Open
    | Closed


type alias Repo =
    { avatar : String
    , examples : List Example
    }


type alias Example =
    { name : String
    , description : String
    }


type SelectedExample
    = Idle
    | Building
    | Built String
    | BuildError


type Status a
    = Loading
    | LoadingSlowly
    | Loaded a
    | Failed


init : Author -> Package -> Model
init author package =
    { author = author
    , package = package
    , repo = Loading
    , descriptionPanel = Open
    , selectedExample = Idle
    }


view : Model -> { title : String, content : Styled.Html Msg }
view model =
    let
        descriptionOpen =
            model.descriptionPanel == Open
    in
    { title = "examples"
    , content =
        stageWrapper
            [ sliderLeft, sliderCenter (not <| descriptionOpen), sliderRight descriptionOpen ]
    }


commonSliderStyles : List Css.Style
commonSliderStyles =
    [ Css.position Css.absolute
    , Css.height (Css.pct 100)
    ]


sliderLeftWidth : Float
sliderLeftWidth =
    25


sliderRightWidth : Float
sliderRightWidth =
    32


centerContentWidth : Float
centerContentWidth =
    460


sliderCenter : Bool -> Styled.Html msg
sliderCenter center =
    div
        [ StyledAttribs.css
            [ Css.width (Css.pct 100)
            , Css.height (Css.pct 100)
            , Css.backgroundColor (Css.hex "#FBFBFB")
            ]
        ]
        [ centerWrapper center [ centerContent ] ]


centerWrapper : Bool -> List (Styled.Html msg) -> Styled.Html msg
centerWrapper center content =
    div
        [ ExamplesStyles.centerWrapper center
        ]
        content


centerContent : Styled.Html msg
centerContent =
    div
        [ StyledAttribs.css
            [ Css.alignSelf Css.center
            , Css.position Css.relative
            ]
        ]
        [ div
            [ StyledAttribs.css
                [ Css.display Css.block
                , Css.width (Css.px centerContentWidth)
                , Css.height (Css.px 590)
                , Css.overflow Css.hidden
                , Css.backgroundColor (Css.hex "#FFFFFF")
                , Css.borderRadius (Css.px 12)
                ]
            ]
            []
        ]


sliderLeft : Styled.Html Msg
sliderLeft =
    div
        [ StyledAttribs.css
            ([ Css.width (Css.pct sliderLeftWidth)
             , Css.left (Css.pct 0)
             ]
                ++ commonSliderStyles
            )
        ]
        [ exampleList ]


sliderRight : Bool -> Styled.Html Msg
sliderRight descriptionOpen =
    let
        resolveTransform =
            if descriptionOpen then
                0

            else
                100
    in
    div
        [ StyledAttribs.css
            ([ Css.width (Css.pct sliderRightWidth)
             , Css.right (Css.pct 0)
             , Css.top (Css.px 0)
             , Css.backgroundColor (Css.hex "#FFFFFF")
             , Css.paddingLeft Grid.halfGrid
             , Css.paddingRight Grid.halfGrid
             , Css.boxSizing Css.borderBox
             ]
                ++ commonSliderStyles
                ++ Transition.transform (Css.translateX <| Css.pct resolveTransform)
            )
        ]
        [ exampleDescription, sliderToggle descriptionOpen ]


stageWrapper : List (Styled.Html msg) -> Styled.Html msg
stageWrapper content =
    div
        [ StyledAttribs.css
            [ Css.top (Css.px Header.navHeight)
            , Css.bottom (Css.px 0)
            , Css.position Css.fixed
            , Css.width (Css.pct 100)
            ]
        ]
        content


exampleList : Styled.Html Msg
exampleList =
    let
        paddingCalc =
            (Css.calc Grid.halfGrid Css.minus (Css.px 2)).value
    in
    div [ StyledAttribs.css [ Css.textAlign Css.right, Css.margin4 (Grid.calc Grid.grid Grid.divide 1.25) (Css.px 0) (Css.px 0) (Css.px 0) ] ]
        [ h2
            [ StyledAttribs.css
                [ Css.fontSize Font.fontSizeH2
                , Css.marginTop Grid.grid
                , Css.property "padding-right" paddingCalc
                ]
            ]
            [ text "Examples" ]
        , ul []
            [ exampleSelector "exampleSelector 1"
            , exampleSelector "exampleSelector 2"
            , exampleSelector "exampleSelector 3"
            , exampleSelector "exampleSelector 4"
            , exampleSelector "exampleSelector 5"
            ]
        ]


exampleDescription : Styled.Html msg
exampleDescription =
    div []
        [ h2 [ StyledAttribs.css [ Css.fontSize Font.fontSizeH2, Css.marginTop Grid.grid ] ]
            [ text "Example Description" ]
        , p [] [ text "Some text goes here about the component and what it can do." ]
        ]


exampleSelector : String -> Styled.Html Msg
exampleSelector name =
    li [ StyledAttribs.css [ Css.listStyleType Css.none, Css.marginBottom (Grid.calc Grid.grid Grid.divide 2.5) ] ]
        [ span [ StyledAttribs.css [ Css.display Css.inlineBlock ] ]
            [ Button.view
                (Button.secondary
                    |> Button.onClick SelectExample
                )
                name
            ]
        ]


sliderToggle : Bool -> Styled.Html Msg
sliderToggle open =
    let
        orientation =
            if open then
                Button.Open

            else
                Button.Closed
    in
    Button.view
        (Button.icon (Button.Triangle orientation)
            |> Button.onClick ToggleDescriptionPanel
        )
        "open slider"


triangle : Styled.Html msg
triangle =
    svg [ height "32", viewBox "0 0 150 300" ] [ polygon [ fill "orange", points "0, 150 150, 0 150,300" ] [] ]



-- UPDATE


type Msg
    = ToggleDescriptionPanel
    | SelectExample


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleDescriptionPanel ->
            let
                panel =
                    case model.descriptionPanel of
                        Open ->
                            Closed

                        _ ->
                            Open
            in
            ( { model | descriptionPanel = panel }, Cmd.none )

        SelectExample ->
            ( model, Cmd.none )
