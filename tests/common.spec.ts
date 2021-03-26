import { removeWhiteSpace } from "../functions/common";
import { expect } from "chai";

describe("removeWhiteSpace", () => {
  it("should remove all white space from string", () => {
    const stringWithWhitespace =
      "confidence man-elm animate height-best example-compiled";
    expect(removeWhiteSpace(stringWithWhitespace)).to.eq(
      "confidenceman-elmanimateheight-bestexample-compiled"
    );
  });
});
