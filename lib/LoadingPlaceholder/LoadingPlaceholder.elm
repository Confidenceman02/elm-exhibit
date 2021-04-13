module LoadingPlaceholder.LoadingPlaceholder exposing
    ( Height(..)
    , MarginBottom(..)
    , Width(..)
    , animated
    , block
    , borderRadius
    , colorVariant
    , defaultBlock
    , height
    , marginBottom
    , view
    , width
    )

import Css
import Css.Animations as CssAnimation
import Html.Styled as Styled exposing (div)
import Html.Styled.Attributes as StyledAttribs
import Styles.Spacing exposing (exSpacingMd)


type Config
    = Config ( BaseConfiguration, Variant )


type Variant
    = Block BlockConfig


type Height
    = Normal
    | Tall
    | TallXl
    | CustomHeight Float


type MarginBottom
    = DefaultMargin
    | Custom Float


type ColorVariant
    = Default


type Width
    = Pct Float
    | Rem Float
    | Px Float


type alias BaseConfiguration =
    { animated : Bool
    , colorVariant : ColorVariant
    , height : Height
    , width : Width
    , marginBottom : MarginBottom
    }


type alias BlockConfiguration =
    { borderRadius : Float
    }


defaultBaseConfiguration : BaseConfiguration
defaultBaseConfiguration =
    { animated = True
    , colorVariant = Default
    , height = Normal
    , width = Pct 100
    , marginBottom = DefaultMargin
    }


defaultBlock : BlockConfig
defaultBlock =
    BlockConfig
        { borderRadius = 21
        }


type BlockConfig
    = BlockConfig BlockConfiguration


block : BlockConfig -> Config
block blockConfig =
    Config ( defaultBaseConfiguration, Block blockConfig )



-- MODIFIERS


animated : Bool -> Config -> Config
animated value (Config ( base, variant )) =
    Config ( { base | animated = value }, variant )


marginBottom : MarginBottom -> Config -> Config
marginBottom m (Config ( base, variant )) =
    Config ( { base | marginBottom = m }, variant )


colorVariant : ColorVariant -> Config -> Config
colorVariant value (Config ( base, variant )) =
    Config ( { base | colorVariant = value }, variant )


height : Height -> Config -> Config
height value (Config ( base, variant )) =
    Config ( { base | height = value }, variant )


width : Width -> Config -> Config
width value (Config ( base, variant )) =
    Config ( { base | width = value }, variant )


borderRadius : Float -> BlockConfig -> BlockConfig
borderRadius br (BlockConfig config) =
    BlockConfig { config | borderRadius = br }



-- VIEWS


view : Config -> Styled.Html msg
view (Config ( base, variant )) =
    case variant of
        Block (BlockConfig config) ->
            div
                [ StyledAttribs.css
                    (baseStyles base
                        ++ withHeightStyles base
                        ++ withMarginBottomStyles base
                        ++ withAnimationStyles base
                        ++ withWidthStyles base
                        ++ withBlockStyles config
                    )
                ]
                []



-- STYLES


baseStyles : BaseConfiguration -> List Css.Style
baseStyles baseConfig =
    [ Css.backgroundColor (Css.hex "#d6d6d6")

    --, Css.borderRadius (Css.px config.borderRadius)
    ]


withHeightStyles : BaseConfiguration -> List Css.Style
withHeightStyles config =
    case config.height of
        Normal ->
            [ Css.height (Css.px 15) ]

        Tall ->
            [ Css.height (Css.px 20) ]

        TallXl ->
            [ Css.height (Css.px 43) ]

        CustomHeight h ->
            [ Css.height (Css.px h) ]


withMarginBottomStyles : BaseConfiguration -> List Css.Style
withMarginBottomStyles config =
    case config.marginBottom of
        DefaultMargin ->
            [ Css.marginBottom exSpacingMd ]

        Custom f ->
            [ Css.marginBottom (Css.px f) ]


withAnimationStyles : BaseConfiguration -> List Css.Style
withAnimationStyles config =
    if config.animated then
        [ Css.animationName <| CssAnimation.keyframes [ ( 0, [ CssAnimation.opacity (Css.num 0.6) ] ), ( 50, [ CssAnimation.opacity (Css.num 1) ] ), ( 100, [ CssAnimation.opacity (Css.num 0.6) ] ) ]
        , Css.animationDuration (Css.sec 1)
        , Css.property "animation-iteration-count" "infinite"
        ]

    else
        []


withWidthStyles : BaseConfiguration -> List Css.Style
withWidthStyles config =
    case config.width of
        Pct f ->
            [ Css.width (Css.pct f) ]

        Rem f ->
            [ Css.width (Css.rem f) ]

        Px f ->
            [ Css.width (Css.px f) ]


withBlockStyles : BlockConfiguration -> List Css.Style
withBlockStyles config =
    [ Css.borderRadius (Css.px config.borderRadius) ]
