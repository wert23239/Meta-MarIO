require "SaveStates"
local lu = require('luaunit')

GoBackOneHalfTest = {}

function GoBackOneHalfTest:setUp()
	initializePool()
	pool.testMode=true
end

function GoBackOneHalfTest:testBackHalf()
	pool.half=true
	pool.netLevel=1
	pool.netWorld=1
	GoBackOneHalfLevel()
	lu.assertEquals(pool.half,false)
	lu.assertEquals(pool.netLevel,1)
	lu.assertEquals(pool.netWorld,1)
	lu.assertEquals(Filename,"States/Level22.state")
end

function GoBackOneHalfTest:testBackWorld()
	pool.half=false
	pool.netLevel=0
	pool.netWorld=1
	GoBackOneHalfLevel()
	lu.assertEquals(pool.half,true)
	lu.assertEquals(pool.netLevel,3)
	lu.assertEquals(pool.netWorld,0)
	lu.assertEquals(Filename,"States/Level145.state")
end

function GoBackOneHalfTest:testFirstWorld()
	pool.half=false
	pool.netLevel=0
	pool.netWorld=0
	GoBackOneHalfLevel()
	lu.assertEquals(pool.half,false)
	lu.assertEquals(pool.netLevel,0)
	lu.assertEquals(pool.netWorld,0)
	lu.assertEquals(Filename,"States/Level11.state")
end

function GoBackOneHalfTest:testFirstWorldHalf()
	pool.half=true
	pool.netLevel=0
	pool.netWorld=0
	GoBackOneHalfLevel()
	lu.assertEquals(pool.half,false)
	lu.assertEquals(pool.netLevel,0)
	lu.assertEquals(pool.netWorld,0)
	lu.assertEquals(Filename,"States/Level11.state")
end

function GoBackOneHalfTest:testFirstWorldHalf()
	pool.half=true
	pool.netLevel=0
	pool.netWorld=0
	GoBackOneHalfLevel()
	lu.assertEquals(pool.half,false)
	lu.assertEquals(pool.netLevel,0)
	lu.assertEquals(pool.netWorld,0)
	lu.assertEquals(Filename,"States/Level11.state")
end

return GoBackOneHalfTest


