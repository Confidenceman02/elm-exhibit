module Repo exposing (Repo, hardCodedRepo_, toString)


type Repo
    = Repo String


toString : Repo -> String
toString (Repo r) =
    r


hardCodedRepo_ : Repo
hardCodedRepo_ =
    Repo "elm-animate-height"
