module Api exposing (Examples, hardCodedExamples)

import Author exposing (Author, hardCodedAuthor_)
import Repo exposing (Repo, hardCodedRepo_)


type Examples
    = Examples Repo


hardCodedExamples : Examples
hardCodedExamples =
    Examples hardCodedRepo_
