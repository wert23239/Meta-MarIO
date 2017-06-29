require "SQL" 
require "Constants"
require "Inputs"

local function SetUpInput()
	controller = {}
	for b = 1,#ButtonNames do
		controller["P1 " .. ButtonNames[b]] = false
	end
	--joypad.set(controller)
	return controller
end

local function CalculateFitness()
	local fitness= math.abs(marioX - NetX)
	if fitness>2 then
		fitness=-10
	end
	if mode==DEATH_ACTION then
		fitness=-20
	end
	return fitness
end


function ResetPositions()
	NetX = memory.readbyte(0x6D) * 0x100 + memory.readbyte(0x86)
	NetScore = memory.readbyte(0x07D8)*100000+memory.readbyte(0x07D9)*10000+memory.readbyte(0x07DA)*1000
	NetScore = NetScore + memory.readbyte(0x07DB)*100 + memory.readbyte(0x07DC)*10 + memory.readbyte(0x07DC)*1
	NetLevel = 1
	NetWorld = 1
end






function InitializeLoop()
	mode=WAIT
	ClearButtons()
	actionframe=0
end


function PressButton(button)
	Buttons=SetUpInput()
	Button=ButtonNames[button]
	Buttons["P1 "..Button]=true
	console.writeline(Buttons)
	--joypad.set(Buttons)
end

function ClearButtons()
	Buttons=SetUpInput()
	Button=ButtonNames[1]
	Buttons["P1 "..Button]=true
	Button=ButtonNames[2]
	Buttons["P1 "..Button]=true
	--joypad.set(Buttons)
end

local function GatherReward()
	getPositions()
	fitness=CalculateFitness()
	UpdateReward(fitness)
end

Open()
savestate.load(Filename) --load Level 1
DummyRow()
DEATH_WAIT,DEATH_ACTION,WAIT,ACTION = 0,1,2,3
local ACTIONTIME=50
actionframe=0
ResetPositions()
ClearButtons()
mode=WAIT
fitness=0
while true do
	joypad.set(Buttons)
	if (mode~=DEATH_ACTION and mode~=DEATH_WAIT) and memory.readbyte(0x000E)==11 then
	   if mode==ACTION then
	      mode=DEATH_ACTION      
	   else
	   	  mode=DEATH_WAIT
	   end	  
	end
	if mode==DEATH_ACTION then
		GatherReward()
		DummyRowDead()
		savestate.load(Filename)
		InitializeLoop()
	end 
	if mode==DEATH_WAIT then
		EraseLastAction()
		DummyRowDead()
		savestate.load(Filename)
		InitializeLoop()
	end 
    if mode==WAIT and emu.checktable()==false then
 		PressButton(emu.getbutton())
 		ResetPositions()
 		mode=ACTION
 	end
 	if mode==ACTION then
 		actionframe=actionframe+1
 	end	
 	if actionframe>=ACTIONTIME then
	    GatherReward()
	    DummyRow()
		InitializeLoop()
 	end

 	emu.frameadvance()
end