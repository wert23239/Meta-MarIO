--[[
LevelChangepool.halfway: Check is Mario has gotten past the current World 
--]]
function LevelChangeHalfway()
	isChange=false
	if pool.marioWorld==0 and pool.marioLevel==0 and marioX>1310 then
		isChange=true
	elseif pool.marioWorld==0 and pool.marioLevel==1 and marioX>1566 then
		isChange=true
	elseif pool.marioWorld==0 and pool.marioLevel==2 and marioX>1054 then
		isChange=true
	elseif pool.marioWorld==1 and pool.marioLevel==0 and marioX>1566 then
		isChange=true
	elseif pool.marioWorld==1 and pool.marioLevel==1 and marioX>1310 then
		isChange=true
	elseif pool.marioWorld==1 and pool.marioLevel==2 and marioX>1812 then
		isChange=true
	elseif pool.marioWorld==2 and pool.marioLevel==0 and marioX>1566 then
		isChange=true
	elseif pool.marioWorld==2 and pool.marioLevel==1 and marioX>1566 then
		isChange=true
	elseif pool.marioWorld==2 and pool.marioLevel==2 and marioX>1054 then
		isChange=true
	elseif pool.marioWorld==3 and pool.marioLevel==0 and marioX>1566 then
		isChange=true
	elseif pool.marioWorld==3 and pool.marioLevel==1 and marioX>1566 then
		isChange=true
	elseif pool.marioWorld==3 and pool.marioLevel==2 and marioX>1054 then
		isChange=true
	elseif pool.marioWorld==4 and pool.marioLevel==0 and marioX>1566 then
		isChange=true
	elseif pool.marioWorld==4 and pool.marioLevel==1 and marioX>1566 then
		isChange=true
	elseif pool.marioWorld==4 and pool.marioLevel==2 and marioX>1054 then
		isChange=true
	elseif pool.marioWorld==5 and pool.marioLevel==0 and marioX>1566 then
		isChange=true
	end
	if isChange and pool.half==false then
		pool.half = true
		Filename = "Level" .. pool.marioWorld+1 .. pool.marioLevel+1 .. 5 ..".state"
		writeFile("Pools/Backups/".. "backup." .. tostring(forms.getthreadNum()) .. "." .. pool.marioWorld+1 .. "." .. pool.marioLevel+1 .. 5 .. "." ..pool.generation .. "." .. forms.gettext(saveLoadFile))
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
	if pool.netLevel~=pool.marioLevel or pool.netWorld~=pool.marioWorld then
		pool.netWorld=pool.marioWorld
		pool.netLevel=pool.marioLevel
		pool.half=false
		Filename = "Level" .. pool.netWorld+1 .. pool.netLevel+1 .. ".state"
		--Filename = "Level" .. "1" .. "1" .. ".state"
		Filename = "States/"..Filename
		
		writeFile("Pools/Backups/".. "backup." .. tostring(forms.getthreadNum()) .. "." .. pool.marioWorld+1 .. "." .. pool.marioLevel+1 .. "." ..pool.generation .. "." .. forms.gettext(saveLoadFile))
		console.writeline("Next Level")
		pool.maxFitness=0
		pool.maxGenerationFitness=0
		--training = true
		NetGeneration = pool.generation
		--resetStaleFitness
	end
end
