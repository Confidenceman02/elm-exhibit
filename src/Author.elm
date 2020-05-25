module Author exposing (Author, hardCodedAuthor_, toString)


type Author
    = Author String


toString : Author -> String
toString (Author a) =
    a


hardCodedAuthor_ : Author
hardCodedAuthor_ =
    Author "Confidenceman02"
