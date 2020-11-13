import redisClientResult from '../../functions/redis/client'
import {expect} from 'chai'
import {Status} from '../../lib/result'
import {initTempSession} from "../../functions/redis/actions";
import {TempSessionMeta} from "../../functions/redis/types";

describe('actions', () => {
  beforeEach(() => {
    if(redisClientResult.Status === Status.Ok) {
      redisClientResult.data.FLUSHALL()
    }
  })
  afterEach((() => {
    if(redisClientResult.Status === Status.Ok) {
      redisClientResult.data.FLUSHALL()
    }
  }))
  describe('initTempSession', () => {
    it('should init a temporary session', async () => {
      // const client = redisClientResult.data
      const tempSessionMeta: TempSessionMeta = {sessionId: "1234", referer: "www.elm-exhibit.com"}
      const tempSessionInitiated = await initTempSession(tempSessionMeta)
      expect(tempSessionInitiated).to.be.true
    })
  })
})