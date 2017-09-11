--[[
LevelChangeHalfway: Check is Mario has gotten past the current World 
--]]
function LevelChangeHalfway()
	isChange=false
	if marioWorld==0 and marioLevel==0 and marioX>1310 then
		isChange=true
	elseif marioWorld==0 and marioLevel==1 and marioX>1566 then
		isChange=true
	elseif marioWorld==0 and marioLevel==2 and marioX>1054 then
		isChange=true
	elseif marioWorld==1 and marioLevel==0 and marioX>1566 then
		isChange=true
	elseif marioWorld==1 and marioLevel==1 and marioX>1310 then
		isChange=true
	elseif marioWorld==1 and marioLevel==2 and marioX>1812 then
		isChange=true
	elseif marioWorld==2 and marioLevel==0 and marioX>1566 then
		isChange=true
	elseif marioWorld==2 and marioLevel==1 and marioX>1566 then
		isChange=true
	elseif marioWorld==2 and marioLevel==2 and marioX>1054 then
		isChange=true
	end
	if isChange and half==false then
		half = true
		Filename = "Level" .. marioWorld+1 .. marioLevel+1 .. 5 ..".state"
		writeFile("Pools/Backups/".. "backup." .. marioWorld+1 .. marioLevel+1 .. 5 ..pool.generation .. "." .. forms.gettext(saveLoadFile))
		Filename = "States/"..Filename
		console.writeline("Next Level Half")
		--resetStaleFitness
	end

end


--[[
LevelChange: Checks if Mario has gotten past the current Level he is on.
if he has update the Filename
--]]
function LevelChange()
	if NetLevel~=marioLevel or NetWorld~=marioWorld then
		NetWorld=marioWorld
		NetLevel=marioLevel
		half=false
		Filename = "Level" .. NetWorld+1 .. NetLevel+1 .. ".state"
		Filename = "States/"..Filename
		writeFile("Pools/Backups/".. "backup." ..NetWorld+1 .. NetLevel+1 .. pool.generation .. "." .. forms.gettext(saveLoadFile))
		console.writeline("Next Level")
		pool.maxFitness=0
		pool.maxGenerationFitness=0
		--training = true
		NetGeneration = pool.generation
		--resetStaleFitness
	end
end
