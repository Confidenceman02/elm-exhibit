module Effect exposing (Effect, Handler, evaluate, map, none, single)


type Effect effectMsg
    = None
    | Single effectMsg


type alias Handler effect msg =
    effect -> Cmd msg


none : Effect effectMsg
none =
    None


single : effectMsg -> Effect effectMsg
single effectMsg =
    Single effectMsg


evaluate : Handler effect msg -> Effect effect -> Cmd msg
evaluate handler effect =
    case effect of
        None ->
            Cmd.none

        Single effectMsg ->
            handler effectMsg


map : (a -> b) -> Effect a -> Effect b
map f effect =
    case effect of
        None ->
            None

        Single a ->
            Single (f a)
