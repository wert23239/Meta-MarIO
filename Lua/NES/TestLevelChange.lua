require "SaveStates"
local lu = require('luaunit')


LevelChangeTest = {}

function LevelChangeTest:setUp()
	initializePool()
	pool.testMode=true
end

function LevelChangeTest:testFirstLevel()
	pool.marioWorld=0
	pool.marioLevel=0
	pool.half=false
	marioX=1510
	Filename=""
	LevelChangeHalfway()
	lu.assertEquals(Filename,"States/Level115.state")
end


return LevelChangeTest