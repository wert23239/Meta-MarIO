TestGoBackOneHalfLevel = require "TestGoBackOneHalfLevel"
TestLevelChange = require "TestLevelChange"
local lu = require('luaunit')

function RunTests()
	
	print("fuck")
	return lu.LuaUnit.run("--output", "text")
end	--client.exit()


