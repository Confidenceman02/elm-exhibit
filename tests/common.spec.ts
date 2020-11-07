import {removeWhiteSpace, Tuple} from "../functions/common";
import { expect } from "chai";
import {Status} from "../functions/types";

describe('common', () => {
  describe('removeWhiteSpace', () => {
    it('should remove all white space from string', () => {
      const stringWithWhitespace = "confidence man-elm animate height-best example-compiled"
      expect(removeWhiteSpace(stringWithWhitespace)).to.eq('confidenceman-elmanimateheight-bestexample-compiled')
    })
  })
  describe('toTuple', () => {
    describe('Err', () => {
      it('should return Err tuple', () => {
        expect(Tuple().Err).to.have.ordered.members([Status.Err, undefined])
      })
    })
    describe('Ok', () => {
      it('should return Ok tuple', () => {
        expect(Tuple().Ok('something')).to.have.ordered.members([Status.Ok, 'something'])
      })
    })
  })
})