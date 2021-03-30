module Styles.Transition exposing (left, opacity, right, scale, transform)

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


right : Pct -> List Style
right current =
    [ Css.right current
    , Transitions.transition [ Transitions.right3 defaultDuration defaultDelay defaultTiming ]
    ]


transform : Transform compatible -> List Style
transform t =
    [ Css.transform t
    , Transitions.transition [ Transitions.transform3 defaultDuration defaultDelay defaultTiming ]
    ]


opacity : Float -> List Style
opacity current =
    [ Css.opacity (Css.num current)
    , Transitions.transition [ Transitions.opacity3 defaultDuration defaultDelay defaultTiming ]
    ]


scale : Float -> List Style
scale current =
    [ Css.transform (Css.scale current)
    , Transitions.transition [ Transitions.transform3 150 defaultDelay Transitions.easeOut ]
    ]
