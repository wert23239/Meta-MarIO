--[[
CalculateLocationCord: Calculates a unique location identifier for the Location
Novelty search hash table
--]]
function CalculateLocationCord()
	--console.writeline("X ".. memory.readbyte(0x86).. " Page " .. memory.readbyte(0x6D) .. " Y " .. marioY )
	--console.writeline( math.floor(marioY/16)*10000+memory.readbyte(0x6D) * 1000  + math.floor(memory.readbyte(0x86)/16) )
	return math.floor(marioY/64)*10000+memory.readbyte(0x6D) * 1000 + math.floor(memory.readbyte(0x86)/64)
end


--[[
CalculateLocationCord: Calculates a unique location identifier for the Species and Genome
Novelty search hash table
--]]
function CalculateSpeciesCord(species,genome)
	return species*100+genome
end


