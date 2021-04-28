import { elmLangPackagesToAuthor, removeWhiteSpace } from "../functions/common";
import { expect } from "chai";
import { ElmLangPackage } from "../functions/types";

describe("removeWhiteSpace", () => {
  it("should remove all white space from string", () => {
    const stringWithWhitespace =
      "confidence man-elm animate height-best example-compiled";
    expect(removeWhiteSpace(stringWithWhitespace)).to.eq(
      "confidenceman-elmanimateheight-bestexample-compiled"
    );
  });
});

describe("elmLangPackagesToAuthor", () => {
  it("should filter elm lang packages to a specific author", () => {
    const packages: ElmLangPackage[] = [
      { name: "elm-explorations/test" },
      { name: "lukewestbyConfidenceman02/http-extra" },
      { name: "Confidenceman02/elm-animate-height" },
      { name: "Confidenceman02/elm-select" },
    ];

    expect(elmLangPackagesToAuthor("Confidenceman02", packages)).to.deep.eq([
      { name: "Confidenceman02/elm-animate-height" },
      { name: "Confidenceman02/elm-select" },
    ]);
  });

  it("should return empty array when author case does not match", () => {
    const packages: ElmLangPackage[] = [
      { name: "elm-explorations/test" },
      { name: "lukewestby/http-extra" },
      { name: "Confidenceman02/elm-animate-height" },
      { name: "Confidenceman02/elm-select" },
    ];

    expect(elmLangPackagesToAuthor("confidenceman02", packages)).to.deep.eq([]);
  });

  it("should filter elm lang packages and only match the author", () => {
    const packages: ElmLangPackage[] = [
      { name: "elm-explorations/test" },
      { name: "lukewestby/Confidenceman02" },
      { name: "Confidenceman02/elm-animate-height" },
      { name: "Confidenceman02/elm-select" },
    ];

    expect(elmLangPackagesToAuthor("Confidenceman02", packages)).to.deep.eq([
      { name: "Confidenceman02/elm-animate-height" },
      { name: "Confidenceman02/elm-select" },
    ]);
  });
});
