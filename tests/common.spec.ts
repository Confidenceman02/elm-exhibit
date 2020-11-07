import {removeWhiteSpace, Result} from "../functions/common";
import { expect } from "chai";
import {Status} from "../functions/types";

describe('removeWhiteSpace', () => {
  it('should remove all white space from string', () => {
    const stringWithWhitespace = "confidence man-elm animate height-best example-compiled"
    expect(removeWhiteSpace(stringWithWhitespace)).to.eq('confidenceman-elmanimateheight-bestexample-compiled')
  })
})

describe('Result', () => {
  describe('Err', () => {
    it('should return Err result', () => {
      expect(Result().Err).to.deep.eq({ Status: Status.Err })
    })
  })
  describe('Ok', () => {
    it('should return Ok result', () => {
      expect(Result().Ok('something')).to.deep.eq({ Status: Status.Ok, data: 'something' })
    })
  })
})