module Effect exposing (Effect, Handler, evaluate, map, none, single)


type Effect effectMsg
    = None
    | Single effectMsg


type alias Handler model effect msg =
    model -> effect -> ( model, Cmd msg )


none : Effect effectMsg
none =
    None


single : effectMsg -> Effect effectMsg
single effectMsg =
    Single effectMsg


evaluate : Handler model effect msg -> model -> Effect effect -> ( model, Cmd msg )
evaluate handler model effect =
    case effect of
        None ->
            ( model, Cmd.none )

        Single effectMsg ->
            handler model effectMsg


map : (a -> b) -> Effect a -> Effect b
map f effect =
    case effect of
        None ->
            None

        Single a ->
            Single (f a)
