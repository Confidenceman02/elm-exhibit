module EffectTest exposing (tests)

import Effect
import Expect
import Test exposing (Test, describe, test)


type ParentEffect
    = ParentEffectWrapper ChildEffectWrapper


type ChildEffectWrapper
    = ChildEffect


tests : Test
tests =
    describe "Effect"
        [ describe "map"
            [ test "is able to map a single Effect msg" <|
                let
                    childEffect =
                        Effect.single ChildEffect
                in
                \() ->
                    Expect.equal (Effect.single (ParentEffectWrapper ChildEffect)) (Effect.map ParentEffectWrapper childEffect)
            , test "is able to map a None Effect msg" <|
                \() ->
                    Expect.equal Effect.none (Effect.map ParentEffectWrapper Effect.none)
            ]
        ]
