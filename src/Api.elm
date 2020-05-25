module Api exposing (Package, hardCodedPackage, packageAuthor)

import Author exposing (Author, hardCodedAuthor_)
import Repo exposing (Repo, hardCodedRepo_)
import Version exposing (Version, hardCodedVersion_, toString)


type Package
    = Package Author Repo Version


packageAuthor : Package -> Author
packageAuthor (Package a _ _) =
    a


hardCodedPackage : Package
hardCodedPackage =
    Package hardCodedAuthor_ hardCodedRepo_ hardCodedVersion_
