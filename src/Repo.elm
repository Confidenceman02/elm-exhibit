module Repo exposing (Repo, toString)


type Repo
    = Repo String


toString : Repo -> String
toString (Repo r) =
    r
