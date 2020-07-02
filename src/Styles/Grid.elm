module Styles.Grid exposing (calc, divide, grid, halfGrid, multiply)

import Css as Css


type Expression
    = Divide
    | Multiply


divide : Expression
divide =
    Divide


multiply : Expression
multiply =
    Multiply


gridDefault : Float
gridDefault =
    1.5


grid : Css.Rem
grid =
    Css.rem gridDefault


halfGrid : Css.Rem
halfGrid =
    calc grid divide 2


calc : Css.Rem -> Expression -> Float -> Css.Rem
calc r e f =
    case e of
        Multiply ->
            Css.rem <| r.numericValue * f

        Divide ->
            Css.rem <| r.numericValue / f
