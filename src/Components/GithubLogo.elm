module Components.GithubLogo exposing (default, view)

import Css
import Html.Styled as Styled exposing (div)
import Html.Styled.Attributes as StyledAttribs
import Styles.Color exposing (exColorWhite)
import Svg.Styled exposing (Svg, path, svg)
import Svg.Styled.Attributes exposing (d, fill, height, viewBox, width)


type Config
    = Config Configuration


type alias Configuration =
    { variant : Variant
    , size : Size
    }


type Variant
    = Default


type Size
    = Medium


defaults : Configuration
defaults =
    { variant = Default
    , size = Medium
    }


default : Config
default =
    Config defaults


view : Config -> Styled.Html msg
view (Config config) =
    div [ StyledAttribs.css [ Css.height (Css.px <| sizeToFloat config.size), Css.width (Css.px <| sizeToFloat config.size) ] ]
        [ svg
            [ height <| String.fromFloat <| sizeToFloat config.size
            , width <| String.fromFloat <| sizeToFloat config.size
            , viewBox "0 0 30 30"
            ]
            [ path
                [ fill exColorWhite.value
                , d "M14.9981 0.312256C6.71625 0.312256 0 7.05476 0 15.3723C0 22.0248 4.2975 27.6685 10.26 29.6616C11.01 29.8004 11.2838 29.3354 11.2838 28.936C11.2838 28.5779 11.2706 27.631 11.2631 26.3748C7.09125 27.2841 6.21 24.3554 6.21 24.3554C5.52938 22.6154 4.545 22.1523 4.545 22.1523C3.18187 21.2185 4.64625 21.2373 4.64625 21.2373C6.15188 21.3441 6.94313 22.7898 6.94313 22.7898C8.28187 25.0904 10.455 24.4266 11.31 24.0404C11.445 23.0673 11.8331 22.4035 12.2625 22.0266C8.9325 21.646 5.43 20.3541 5.43 14.5848C5.43 12.9404 6.015 11.596 6.975 10.5423C6.81938 10.1616 6.30562 8.62976 7.12125 6.55788C7.12125 6.55788 8.38125 6.15288 11.2463 8.10101C12.4425 7.76726 13.725 7.60038 15.0019 7.59476C16.275 7.60226 17.5594 7.76726 18.7575 8.10288C21.6206 6.15476 22.8787 6.55976 22.8787 6.55976C23.6962 8.63351 23.1825 10.1635 23.0287 10.5441C23.9906 11.5979 24.57 12.9423 24.57 14.5866C24.57 20.371 21.0637 21.6441 17.7225 22.0173C18.2606 22.4823 18.7406 23.401 18.7406 24.8054C18.7406 26.8191 18.7219 28.4429 18.7219 28.936C18.7219 29.3391 18.9919 29.8079 19.7531 29.6598C25.7062 27.6648 30 22.0229 30 15.3723C30 7.05476 23.2838 0.312256 14.9981 0.312256Z"
                ]
                []
            ]
        ]


sizeToFloat : Size -> Float
sizeToFloat s =
    case s of
        Medium ->
            34
