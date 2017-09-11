-- Original Code is by SethBling
-- Feel free to use this code, but please do not redistribute it.
-- Intended for use with the BizHawk emulator and Super Mario World or Super Mario Bros. ROM.
-- For SMW, make sure you have a save state named "DP1.state" at the beginning of a level,
-- and put a copy in both the Lua folder and the root directory of BizHawk.
-- Keep this top in mind
--[[
This is only for to change what game it is.
This sets what the save state
As well as what buttons are used
--]]
--client.SetGameExtraPadding(0,0,0,0); Used for
--C:\Users\Alex\Source\Repos\BizHawk\BizHawk.Client.EmuHawk\tools\Lua\Libraries\EmuLuaLibrary.Client
--public static void SetGameExtraPadding(int left, int top, int right, int bottom)
--		{
--            //GlobalWin.DisplayManager.GameExtraPadding = new System.Windows.Forms.Padding(left, top, right, bottom);
--            //GlobalWin.MainForm.FrameBufferResized();
--            GlobalWin.MainForm.PauseEmulator();
--		}




require "Constants"
require "Inputs"
require "NeuralNetwork"
require "Pools"
require "SaveStates"
require "Forms"
require "Timeout"

M=require "lua-sendinput/SendInput"
--M.key_press(Keys.Q,200)
require "lua-sendinput/Keys"


--See if a multithread inilization or regular inilization
if pool == nil then
	if tonumber(forms.getthreadNum())==-1 then
		initializePool()
		writeMultiIntial("Initial")
		Population=tonumber(forms.getthreadNum())
		client.SetGameExtraPadding(pool.generation,0,0,0)
	elseif tonumber(forms.getthreadNum())>0  then
		loadFileMulti("Muation")
		mutate(pool.species[0].genome[0])
	else
		initializePool()
	end
	
end

--Set Dimensions of GUI
FitnessBox(140,40,600,700)

--makes the OnExit function work onExit
event.onexit(onExit)



--Infinte Fitness Loop
while true do
	--Sets the Top Bar Color
	local backgroundColor = 0xD0FFFFFF
	--client.SetGameExtraPadding(pool.generation,0,0,0);
	--Draws the Top Box


 	gui.drawBox(0, 0, 300, 40, backgroundColor, backgroundColor)


	local species = pool.species[pool.currentSpecies]
	local genome = species.genomes[pool.currentGenome]


	--showNetwork Boolean this then draws the bottom section
	if forms.ischecked(showNetwork) then
		displayGenome(genome)
	end


	if(inPlay()) then
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

		--If the orgranism has not evolved within the allotted time end the run
		if timeout + timeoutBonus <= 0  or TimeoutAuto == true then
			TimeoutAuto=false
			local fitness = 0
			local fitnesscheck={}
			for slot=0,2 do
			fitnesscheck[slot]=0
			end
			genome.ran=true

			
			if  pool.generation - NetGeneration  > 20  and training == true then 
				training = false
				savestate.load(Filename)
			end
			--loadstate  
			--fitness equal how right subtracted from how long it takes
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
			--sort fitnesscheck
			table.sort(fitnesscheck)
		
			fitness=fitnesscheck[2]
			--Extra bonus for compeletting the level

			--Mark it is done
			if fitness == 0 then
				fitness = -1
			end
			if NoFitness == true then
				fitness= fitness -20
			end
			if(tonumber(forms.getthreadNum())>0) then
				writeMultiGenome("Genome"..tonumber(forms.getthreadNum()))
				client.SetGameExtraPadding(pool.generation,0,0,0)
			end


			--Set the current genomes fitness to the local fitness
			if fitness > genome.fitness then
				genome.fitness = fitness
			end
			


			--If newfitness record then
			if fitness > pool.maxFitness then
				--Set the MaxFitness for the gene pool
				pool.maxFitness = fitness
				--Create a backup
				
			end

			--console.writeline("Gen " .. pool.generation .. " species " .. pool.currentSpecies .. " genome " .. pool.currentGenome .. " fitness: " .. fitness)

			--console.writeline("World " .. pool.marioWorld .. " Level " .. pool.marioLevel .. " pool.half ")
			--console.writeline(pool.half)
			pool.currentSpecies = 1
			pool.currentGenome = 1


			while fitnessAlreadyMeasured() do
				nextGenome()
			end
			--Resetup Run
			initializeRun()
		end

		local measured = 0
		local total = 0

		--Count how many Organisms have fun
		for _,species in pairs(pool.species) do
			for _,genome in pairs(species.genomes) do
				total = total + 1
				if genome.fitness ~= 0 then
					measured = measured + 1
				end
			end
		end

		--Displays in the banner the Generation, species, and genome
		--Displays Fitness
		--Displays Max Fitness
		local fitnessDisplay = {}
		for slot=0,2 do
			fitnessDisplay[slot]=0
		end
		if forms.ischecked(RightmostFitness) then
				fitnessDisplay[0] = (rightmost - NetX)*tonumber(forms.gettext(RightmostAmount))
		end
		if forms.ischecked(NoveltyFitness) then
				fitnessDisplay[1] = CurrentNSFitness*tonumber(forms.gettext(NoveltyAmount))
		end
		if forms.ischecked(ScoreFitness) then
				fitnessDisplay[2] = tonumber(forms.gettext(ScoreAmount))*(marioScore - NetScore)
		end
		gui.drawText(0, 12, "Gen " .. pool.generation .. " species " .. pool.currentSpecies .. " genome " .. pool.currentGenome .. " (" .. math.floor(measured/total*100) .. "%)", 0xFF000000, 11)
		gui.drawText(0, 24, "RM: " .. math.floor(fitnessDisplay[0]), 0xFF000000, 11)
		gui.drawText(80, 24, "NS: " .. math.floor(fitnessDisplay[1]), 0xFF000000, 11)
		gui.drawText(160, 24, "SO: " .. math.floor(fitnessDisplay[2]), 0xFF000000, 11)
		
	--Manual Update of Frame
	pool.currentFrame = pool.currentFrame + 1
	else
		getPositions()
		if not training then
			LevelChange()
			LevelChangehalfway()
		end
		if memory.readbyte(0x071E)==11 then
		   TimeoutAuto=true
		   NoFitness=true
		   if training==false and forms.ischecked(showContinousDeath) then
				savestate.rewind()

		   end
		end

	end


	--Actual Update of Frame
	emu.frameadvance();
end