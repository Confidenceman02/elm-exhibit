import redisClientResult from '../../functions/redis/client'
import {expect, assert} from 'chai'
import { Status } from '../../lib/result'
import {initTempSession} from "../../functions/redis/actions";
import {TempSessionMeta} from "../../functions/redis/types";

describe('actions', () => {
  describe('initTempSession', () => {
    it('should init a temporary session', async () => {
      if (redisClientResult.Status === Status.Ok) {
        // const client = redisClientResult.data
        const tempSessionMeta: TempSessionMeta = {sessionId: "1234", referer: "www.elm-exhibit.com"}
        const tempSessionCreated = await initTempSession(tempSessionMeta)
        expect(tempSessionCreated).to.be.true
      } else {
        assert.fail("Redis client not found")
      }
    })
  })

})