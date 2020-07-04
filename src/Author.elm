module Author exposing (Author, hardCodedAuthor_, parser, toString)

import Url.Parser as Parser exposing (Parser)


type Author
    = Author String


toString : Author -> String
toString (Author a) =
    a


hardCodedAuthor_ : Author
hardCodedAuthor_ =
    Author "Confidenceman02"


parser : Parser (Author -> a) a
parser =
    Parser.map Author Parser.string
