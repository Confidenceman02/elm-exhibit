module Version exposing (Version, hardCodedVersion_, toString)


type Version
    = Version String


toString : Version -> String
toString (Version v) =
    v


hardCodedVersion_ : Version
hardCodedVersion_ =
    Version "2.0.1"
