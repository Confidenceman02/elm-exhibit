import {removeWhiteSpace, Tuple} from "../functions/common";
import { expect } from "chai";
import {Status} from "../functions/types";

describe('removeWhiteSpace', () => {
  it('should remove all white space from string', () => {
    const stringWithWhitespace = "confidence man-elm animate height-best example-compiled"
    expect(removeWhiteSpace(stringWithWhitespace)).to.eq('confidenceman-elmanimateheight-bestexample-compiled')
  })
})

describe('toTuple', () => {
  describe('Err', () => {
    it('should return Err tuple', () => {
      expect(Tuple().Err).to.deep.eq({ Status: Status.Err })
    })
  })
  describe('Ok', () => {
    it('should return Ok tuple', () => {
      expect(Tuple().Ok('something')).to.deep.eq({ Status: Status.Ok, data: 'something' })
    })
  })
})