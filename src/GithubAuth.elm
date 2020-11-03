module GithubAuth exposing (CallBackParams, Referer, callBackParamsParser, stateStringFromParams)

import Url.Parser.Query as Query exposing (Parser)


type CallBackParams
    = CallBackParams TempCode State


type TempCode
    = TempCode String


type State
    = State String


type Referer
    = Referer String


stateStringFromParams : CallBackParams -> String
stateStringFromParams (CallBackParams _ (State state)) =
    state



{-
   State is an encoded JSON string in base64 that holds
   some basic user info e.g. ""sessionId": "1234", "referer": "www.somewhere.com"".
-}


toState : String -> State
toState state =
    State state


callBackParamsParser : Parser (Maybe CallBackParams)
callBackParamsParser =
    Query.map2 (\code state -> resolveParsedParams code state) (Query.string "code") (Query.string "state")


resolveParsedParams : Maybe String -> Maybe String -> Maybe CallBackParams
resolveParsedParams code state =
    Maybe.map2 (\c s -> CallBackParams (TempCode c) (toState s)) code state
