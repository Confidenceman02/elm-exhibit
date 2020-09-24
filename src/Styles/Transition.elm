module Styles.Transition exposing (left, transform)

import Css exposing (Pct, Style, Transform)
import Css.Transitions as Transitions exposing (Transition)


defaultTiming =
    Transitions.cubicBezier 0.16 0.68 0.43 0.99


defaultDuration : Float
defaultDuration =
    300


defaultDelay : Float
defaultDelay =
    0


left : Pct -> List Style
left current =
    [ Css.left current
    , Transitions.transition [ Transitions.left3 defaultDuration defaultDelay defaultTiming ]
    ]


transform : Transform compatible -> List Style
transform t =
    [ Css.transform t
    , Transitions.transition [ Transitions.transform3 defaultDuration defaultDelay defaultTiming ]
    ]
