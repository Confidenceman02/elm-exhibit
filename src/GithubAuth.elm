module GithubAuth exposing (CallBackParams, Referer, callBackParamsParser, callBackParamsToUrlParams, refererToString, stateStringFromParams, toReferer)

import Url.Builder as UrlBuilder exposing (QueryParameter)
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


tempCodeStringFromParams : CallBackParams -> String
tempCodeStringFromParams (CallBackParams (TempCode code) _) =
    code


{-|

    State is an encoded JSON string in base64 that holds
    some basic user info e.g. ""sessionId": "1234", "referer": "www.somewhere.com"".

-}
toState : String -> State
toState state =
    State state


toReferer : String -> Referer
toReferer s =
    Referer s


refererToString : Referer -> String
refererToString (Referer r) =
    r


callBackParamsParser : Parser (Maybe CallBackParams)
callBackParamsParser =
    Query.map2 (\code state -> resolveParsedParams code state) (Query.string "code") (Query.string "state")


resolveParsedParams : Maybe String -> Maybe String -> Maybe CallBackParams
resolveParsedParams code state =
    Maybe.map2 (\c s -> CallBackParams (TempCode c) (toState s)) code state


callBackParamsToUrlParams : CallBackParams -> List QueryParameter
callBackParamsToUrlParams params =
    [ UrlBuilder.string "code" (tempCodeStringFromParams params), UrlBuilder.string "state" (stateStringFromParams params) ]
