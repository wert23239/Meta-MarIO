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




--[[
NoveltyTimeoutFunction:  When called checks if cordinate is not seen
before by orgranism. These cordinates are XbyX blocks not just a single pixel.
--]]
function NoveltyTimeoutFunction()
	--Gain cordinates and species with hashes
	local cordLocation=CalculateLocationCord() --y/16*10000+page*1000+x/16*1
	local cordSpecies=CalculateSpeciesCord(pool.currentSpecies,pool.currentGenome) --speices*100+genome*1

	if pool.landscape[tostring(cordLocation)]==nil then
		pool.landscape[tostring(cordLocation)]={}
	end

	if not pool.landscape[tostring(cordLocation)][tostring(cordSpecies)]==true then
		pool.landscape[tostring(cordLocation)][tostring(cordSpecies)]=true
		if forms.ischecked(NoveltyTimeout) then
			timeout = tonumber(forms.gettext(TimeoutConstantText))
			--GainNoveltyFitness(tostring(cordLocation))
		end
	end
end


--[[
NoveltyTimeoutFunction:  When called checks if cordinate is not seen
before by orgranism. These cordinates are XbyX blocks not just a single pixel.
--]]
function MarioTimeoutFunction()
	if marioX > rightmost then
		rightmost = marioX
		if forms.ischecked(RightmostTimeout) then
			timeout = tonumber(forms.gettext(TimeoutConstantText))
		end
	end
	if marioX < leftmost then
		leftmost=marioX
		if forms.ischecked(RightmostTimeout) then
			timeout = tonumber(forms.gettext(TimeoutConstantText))
		end
	end
	if marioY > upmost then
		upmost=marioY
		if forms.ischecked(RightmostTimeout) then
			timeout = tonumber(forms.gettext(TimeoutConstantText))
		end
	end
end


--[[
CallTimeoutFunction: Function to call all timeouts in current use 
--]]
function CallTimeoutFunctions()

	--if RightmostPage<marioPage then
	--	RightmostPage=marioPage

	--Novelty Timeout Function called when Novelty Fitness or Timeout is on
	if forms.ischecked(NoveltyFitness) or forms.ischecked(NoveltyTimeout) then
		NoveltyTimeoutFunction()
	end


	--Mario Timeout Function called when Rightmost Fitness or Timeout is on
	if forms.ischecked(RightmostFitness) or forms.ischecked(RightmostTimeout) then
		MarioTimeoutFunction()
	end
end