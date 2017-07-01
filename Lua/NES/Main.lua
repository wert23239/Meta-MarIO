require "Constants"
require "Inputs"
require "NeuralNetwork"
require "Pools"
require "SaveStates"
require "Forms"
require "Timeout"
require "SQL"



-- local function SetUpInput()
-- 	controller = {}
-- 	for b = 1,#ButtonNames do
-- 		controller["P1 " .. ButtonNames[b]] = false
-- 	end
-- 	--joypad.set(controller)
-- 	return controller
-- end

-- local function CalculateFitness()
-- 	fitness= math.abs(marioX - NetX)
-- 	if fitness>2 then
-- 		fitness=-10
-- 	end
-- 	if mode==DEATH_ACTION then
-- 		fitness=-20
-- 	end
-- 	return fitness
-- end


-- function ResetPositions()
-- 	NetX = memory.readbyte(0x6D) * 0x100 + memory.readbyte(0x86)
-- 	NetScore = memory.readbyte(0x07D8)*100000+memory.readbyte(0x07D9)*10000+memory.readbyte(0x07DA)*1000
-- 	NetScore = NetScore + memory.readbyte(0x07DB)*100 + memory.readbyte(0x07DC)*10 + memory.readbyte(0x07DC)*1
-- 	NetLevel = 1
-- 	NetWorld = 1
-- end









-- function PressButton(button)
-- 	Buttons=SetUpInput()
-- 	Button=ButtonNames[button]
-- 	Buttons["P1 "..Button]=true	
-- 	--joypad.set(Buttons)
-- end

-- function ClearButtons()
-- 	Buttons=SetUpInput()
-- 	Button=ButtonNames[1]
-- 	Buttons["P1 "..Button]=true
-- 	Button=ButtonNames[2]
-- 	Buttons["P1 "..Button]=true
-- 	--joypad.set(Buttons)
-- end

local function GatherReward()
	fitness=GeneticAlgorithmLoop()
	UpdateReward(fitness)
end

function GeneticAlgorithmLoop()
	local Alive=true
	local GlobalFitness=0
	while Alive do

		local species = pool.species[pool.currentSpecies]
		local genome = species.genomes[pool.currentGenome]

		--Every 5 frames evaluate the current orgranism
		if pool.currentFrame%5 == 0 then
				evaluateCurrent()
		end

		--Sets the output to whatever the netowrk chooses
		joypad.set(controller)

		--Get Postion of Mario reading the Hex Bits
		getPositions()

		--Refeshes Timeout
		if pool.currentFrame%4 == 0 then
			CallTimeoutFunctions()
		end

		--Subtract one time unit each loop
		timeout = timeout - 1

		--Each extra four frames give mario and extra bonus living amount
		local timeoutBonus = pool.currentFrame / 4

		if timeout + timeoutBonus <=0 or memory.readbyte(0x000E)==11 then
			
			Alive=false
			--If Dead
			

			local fitness = 0
			local fitnesscheck={}
			for slot=0,2 do
				fitnesscheck[slot]=0
			end
			genome.ran=true

			if forms.ischecked(RightmostFitness) then
				fitnesscheck[0] = tonumber(forms.gettext(RightmostAmount))*(rightmost - NetX)
				genome.rightmostFitness=fitnesscheck[0]
			end
			if forms.ischecked(ScoreFitness) then
				fitnesscheck[1] = fitness+tonumber(forms.gettext(ScoreAmount))*(marioScore - NetScore)
			end
			if forms.ischecked(NoveltyFitness) then
				fitnesscheck[2] = fitness +tonumber(forms.gettext(NoveltyAmount))*(CurrentNSFitness)
			end

			table.sort(fitnesscheck)
		
			fitness=fitnesscheck[2]

			if gameinfo.getromname() == "Super Mario Bros." and rightmost > 3186 then
				fitness = fitness + 1000
			end

			if fitness == 0 then
				fitness = -1
			end

			if memory.readbyte(0x000E)==11 then
				mode=DEATH_ACTION
				fitness= fitness-20
			else 
				mode=WAIT
				DummyRow()
			end

			if fitness > genome.fitness then
				genome.fitness = fitness
			end

			pool.currentSpecies = 1
			pool.currentGenome = 1

			while fitnessAlreadyMeasured() do
				nextGenome()
			end
			initializeRun()

		end

		pool.currentFrame = pool.currentFrame + 1
		emu.frameadvance()
	end	
	return GlobalFitness



end


DEATH_WAIT,DEATH_ACTION,WAIT,ACTION = 0,1,2,3
mode=WAIT



Open()
savestate.load(Filename) --load Level 1
FitnessBox(140,40,600,700) --Set Dimensions of GUI
DummyRow()




initializePool()
UpdateGenes(CollectGenes())



while true do
	if (mode~=DEATH_ACTION) and memory.readbyte(0x000E)==11 then    
	   mode=DEATH_WAIT 
	end
	if mode==DEATH_ACTION then
		DummyRowDead()
		savestate.load(Filename)
		mode=WAIT
	end 
	if mode==DEATH_WAIT then
		EraseLastAction()
		DummyRowDead()
		savestate.load(Filename)
		mode=WAIT
	end 
    if mode==WAIT and emu.checktable()==false then
 		mode=ACTION
 	end
 	if mode==ACTION then
 		GatherReward()
 	end	

 	emu.frameadvance()
end