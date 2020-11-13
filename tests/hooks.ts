const redisClientResult =  require('../built-lambda/redis/client')
const Status = require('../lib/result').Status

exports.mochaHooks = {
    afterEach: (done) => {
        console.log("FLUSHING DB")
        return done()
    }
}
