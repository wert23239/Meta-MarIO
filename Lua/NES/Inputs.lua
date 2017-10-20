--[[
GetPostions: Return the postion of Mario Using in game Hex Bits
--]]
function getPositions()
	--In the classic game the X bit is done using a paging bit first
	--This allows you to have bigger numbers than 256
	--marioPage=memory.readbyte(0x6D)
	marioX = memory.readbyte(0x6D) * 0x100 + memory.readbyte(0x86)
	marioY = memory.readbyte(0x03B8)+16
	marioScore = memory.readbyte(0x7D8)*100000+memory.readbyte(0x07D9)*10000+memory.readbyte(0x07DA)*1000
	marioScore = marioScore+memory.readbyte(0x07DB)*100 + memory.readbyte(0x07DC)*10 + memory.readbyte(0x07DC)*1
	pool.marioLevel = memory.readbyte(0x075C)
	pool.marioWorld = memory.readbyte(0x075F)
	--marioScore= 19
	screenX = memory.readbyte(0x03AD)
	screenY = memory.readbyte(0x03B8)
end


--[[
getTile: Return each of the tiles used for the input
Return:  Whether the tile is
--]]
function getTile(dx, dy)
	--Dx plus what page they are on`
	local x = marioX + dx + 8
	local y = marioY + dy - 16
	local page = math.floor(x/256)%2


	local subx = math.floor((x%256)/16)
	local suby = math.floor((y - 32)/16)
	local addr = 0x500 + page*13*16+suby*16+subx


	if suby >= 13 or suby < 0 then
		return 0
	end

	if memory.readbyte(addr) ~= 0 and memory.readbyte(addr``````) ~= 0xC2 then
		return 1
	else
		return 0
	end
end


--[[
GetSprites: Return the monster if they are on a tile
--]]
function getSprites()
	local sprites = {}

	for slot=0,6 do
		--Reads the four slots and see if there are monsters 000F-0012
		local enemy = memory.readbyte(0xF+slot)
		--What page number an enemy is on and what's it's x and y
		
		if enemy ~= 0 then
			local ex = memory.readbyte(0x6E + slot)*0x100 + memory.readbyte(0x87+slot)
			local ey = memory.readbyte(0xCF + slot)+24
			local obj= memory.readbyte(0x0016+slot)

			--Go to the end of the list no append
			--Add the tuple X and Y of each monster
			sprites[#sprites+1] = {["x"]=ex,["y"]=ey,["obj"]=obj}
		end
	end

	return sprites
end



--[[
GetInputs: Uses the previous functions to generates all inputs
--]]
function getInputs()


	getPositions()

	sprites = getSprites()
	local inputs = {}
	local block=0
	--For loop dy from negative 16 times the BoxRadius to postive 16 times the BoxRadius incrementing by 16
	--It will loop BoxRadius*Two
	for dy=-BoxRadius*16,BoxRadius*16,16 do
		--Do the same thing for y's
		for dx=-BoxRadius*16,BoxRadius*16,16 do
			--Initializes all inputs to 0
			inputs[#inputs+1] = 0



			tile = getTile(dx, dy)
			--If the current location is a block and above the screen set input to 1
			if (tile == 1 and marioY+dy < 0x1B0) or block>0 then
				block=block-1
				inputs[#inputs] = 1
			end
			--If the current tile is then where a monster is set it to -1
			for i = 1,#sprites do
				distx = math.abs(sprites[i]["x"] - (marioX+dx))
				disty = math.abs(sprites[i]["y"] - (marioY+dy))
				if distx <= 8 and disty <= 8 then
					if sprites[i]["obj"]>=0x24 and sprites[i]["obj"]<=0x28 then
						inputs[#inputs]=1
						block=2
					elseif sprites[i]["obj"]==0x2B then
						inputs[#inputs]=1
						block=1
						blocky=7
					elseif sprites[i]["obj"]==0x2C then
						inputs[#inputs]=1
						block=1

						--inputs[#inputs-(7*BoxRadius*2+6)]=1
						--inputs[#inputs-(7*BoxRadius*2+6+1)]=1
					else 
						inputs[#inputs] = -1
					end
				end
			end
		end
	end

	for dy=-BoxRadius*16,BoxRadius*16,16 do
		--Do the same thing for y's
		for dx=-BoxRadius*16,BoxRadius*16,16 do
			--Initializes all inputs to 0
			inputs[#inputs+1] = 0


			tile = getTile(dx, dy)
			--If the current location is a block and above the screen set input to 1
			if tile == 0 and marioY+dy < 0x1B0 then
				inputs[#inputs] = 1

			end
		end
	end


	return inputs
end
