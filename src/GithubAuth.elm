module GithubAuth exposing (CallBackParams, callBackParamsParser)

import Session
import Url.Parser.Query as Query exposing (Parser)


type CallBackParams
    = CallBackParams TempCode Session.SessionId


type TempCode
    = TempCode String


callBackParamsParser : Parser (Maybe CallBackParams)
callBackParamsParser =
    Query.map2 (\code sessionId -> resolveParsedParams code sessionId) (Query.string "code") (Query.string "state")


resolveParsedParams : Maybe String -> Maybe String -> Maybe CallBackParams
resolveParsedParams code seshId =
    Maybe.map2 (\c id -> CallBackParams (TempCode c) (Session.toSessionId id)) code seshId
