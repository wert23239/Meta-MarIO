--[[
LevelChangeHalfway: Check is Mario has gotten past the current World 
--]]
function LevelChangeHalfway()
	isChange=false
	if NetLevel==0 and rightmost>1310 then
		isChange=true
	elseif NetLevel==1 and rightmost>1566 then
		isChange=true
	elseif NetLevel==2 and rightmost>1054 then
		isChange=true
	end
	if isChange and half==false then
		half = true
		Filename = "Level" .. NetWorld+1 .. NetLevel+1 .. 5 ..".state"
		writeFile("Pools/Backups/".. "backup." .. NetWorld+1 .. NetLevel+1 .. 5 ..pool.generation .. "." .. forms.gettext(saveLoadFile))
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
		--training = true
		NetGeneration = pool.generation
		--resetStaleFitness
	end
end
