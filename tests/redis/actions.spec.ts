import redisClientResult from '../../functions/redis/client'
import {expect} from 'chai'
import {Status} from '../../lib/result'
import {createUser, initTempSession, initSession, tempSessionExists, getUser} from "../../functions/redis/actions";
import {TempSession} from "../../functions/redis/types";
import {GithubUserData} from "../../functions/types";

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
      const tempSession: TempSession = {sessionId: "1234", referer: "www.elm-exhibit.com"}
      const tempSessionInitiated = await initTempSession(tempSession)
      expect(tempSessionInitiated).to.be.true
    })
  })
  describe('initSession', () => {
    it('should init a session', async () => {
      const sessionId = "1234"
      const gitUserData: GithubUserData = {login: "ConfidenceMan02", id: 2345, avatar_url: 'www.bs.com'}
      const sessionInitiated = await initSession(sessionId, gitUserData)
      expect(sessionInitiated).to.be.true
    })
  })
  describe('tempSessionExists', () => {
    it('should find a temp session', async () => {
      const tempSession: TempSession = {sessionId: "1234", referer: "www.elm-exhibit.com"}
      await initTempSession(tempSession)
      const foundTempSession = await tempSessionExists(tempSession)
      expect(foundTempSession).to.be.true
    })
  })
  describe('createUser', () => {
    it('should create a user', async () => {
      const gitUserData: GithubUserData = { login: "ConfidenceMan02", id: 2345, avatar_url: 'www.bs.com' }
      const userCreated = await createUser(gitUserData)
      expect(userCreated).to.be.true
    })
  })
  describe('getUser', () => {
    it('should get a user', async () => {
      const gitUserData: GithubUserData = { login: "Confidenceman02", id: 2345, avatar_url: 'www.bs.com' }
      await createUser(gitUserData)
      const user = await getUser(gitUserData.id)
      expect(user).to.deep.eq({Status: Status.Ok, data: { username: 'Confidenceman02', userId: 2345, avatarUrl: 'www.bs.com' } })
    })
  })
})