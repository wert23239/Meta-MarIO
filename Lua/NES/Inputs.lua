--[[
GetPostions: Return the postion of Mario Using in game Hex Bits
--]]
function getPositions()

	--If statements for which mario game
	if gameinfo.getromname() == "Super Mario World (USA)" then

		--Mario X and Y bits are Both 2 Byte Words
		marioX = memory.read_s16_le(0x94)
		marioY = memory.read_s16_le(0x96)
		local layer1x = memory.read_s16_le(0x1A);
		local layer1y = memory.read_s16_le(0x1C);

		screenX = marioX-layer1x
		screenY = marioY-layer1y
	elseif gameinfo.getromname() == "Super Mario Bros." then

		--In the classic game the X bit is done using a paging bit first
		--This allows you to have bigger numbers than 256
		marioX = memory.readbyte(0x6D) * 0x100 + memory.readbyte(0x86)
		marioY = memory.readbyte(0x03B8)+16
		marioScore = memory.readbyte(0x7D8)*100000+memory.readbyte(0x07D9)*10000+memory.readbyte(0x07DA)*1000
		marioScore = marioScore+memory.readbyte(0x07DB)*100 + memory.readbyte(0x07DC)*10 + memory.readbyte(0x07DC)*1
		marioLevel = memory.readbyte(0x075C)
		marioWorld = memory.readbyte(0x075F)
		--marioScore= 19
		screenX = memory.readbyte(0x03AD)
		screenY = memory.readbyte(0x03B8)
	end
end


--[[
getTile: Return each of the tiles used for the input
Return:  Whether the tile is
--]]
function getTile(dx, dy)
	if gameinfo.getromname() == "Super Mario World (USA)" then

		--Find the exact tile and get the offset
		x = math.floor((marioX+dx+8)/16)
		y = math.floor((marioY+dy)/16)

		--Read the byte of that dx,dy
		return memory.readbyte(0x1C800 + math.floor(x/0x10)*0x1B0 + y*0x10 + x%0x10)
	elseif gameinfo.getromname() == "Super Mario Bros." then

		--Dx plus what page they are on
		local x = marioX + dx + 8
		local y = marioY + dy - 16
		local page = math.floor(x/256)%2


		local subx = math.floor((x%256)/16)
		local suby = math.floor((y - 32)/16)
		local addr = 0x500 + page*13*16+suby*16+subx


		if suby >= 13 or suby < 0 then
			return 0
		end

		if memory.readbyte(addr) ~= 0 then
			return 1
		else
			return 0
		end
	end
end

--[[
GetSprites: Return the monster if they are on a tile
--]]
function getSprites()
	if gameinfo.getromname() == "Super Mario World (USA)" then
		local sprites = {}
		for slot=0,11 do
			local status = memory.readbyte(0x14C8+slot)
			if status ~= 0 then
				spritex = memory.readbyte(0xE4+slot) + memory.readbyte(0x14E0+slot)*256
				spritey = memory.readbyte(0xD8+slot) + memory.readbyte(0x14D4+slot)*256
				sprites[#sprites+1] = {["x"]=spritex, ["y"]=spritey}
			end
		end

		return sprites
	elseif gameinfo.getromname() == "Super Mario Bros." then
		local sprites = {}
		for slot=0,4 do
			--Reads the four slots and see if there are monsters 000F-0012
			local enemy = memory.readbyte(0xF+slot)
			--What page number an enemy is on and what's it's x and y
			if enemy ~= 0 then
				local ex = memory.readbyte(0x6E + slot)*0x100 + memory.readbyte(0x87+slot)
				local ey = memory.readbyte(0xCF + slot)+24
				--Go to the end of the list no append
				--Add the tuple X and Y of each monster
				sprites[#sprites+1] = {["x"]=ex,["y"]=ey}
			end
		end

		return sprites
	end
end


--[[
GetExtendedSprites: Only used for SNES
--]]
function getExtendedSprites()
	if gameinfo.getromname() == "Super Mario World (USA)" then
		local extended = {}
		for slot=0,11 do
			local number = memory.readbyte(0x170B+slot)
			if number ~= 0 then
				spritex = memory.readbyte(0x171F+slot) + memory.readbyte(0x1733+slot)*256
				spritey = memory.readbyte(0x1715+slot) + memory.readbyte(0x1729+slot)*256
				extended[#extended+1] = {["x"]=spritex, ["y"]=spritey}
			end
		end

		return extended
	elseif gameinfo.getromname() == "Super Mario Bros." then
		return {}
	end
end


--[[
GetInputs: Uses the previous functions to generates all inputs
--]]
function getInputs()


	getPositions()

	sprites = getSprites()
	extended = getExtendedSprites()

	local inputs = {}
	--For loop dy from negative 16 times the BoxRadius to postive 16 times the BoxRadius incrementing by 16
	--It will loop BoxRadius*Two
	for dy=-BoxRadius*16,BoxRadius*16,16 do
		--Do the same thing for y's
		for dx=-BoxRadius*16,BoxRadius*16,16 do
			--Initializes all inputs to 0
			inputs[#inputs+1] = 0


			tile = getTile(dx, dy)
			--If the current location is a block set input to 1
			if tile == 1 and marioY+dy < 0x1B0 then
				inputs[#inputs] = 1
			end
			--If the current tile is then where a monster is set it to -1
			for i = 1,#sprites do
				distx = math.abs(sprites[i]["x"] - (marioX+dx))
				disty = math.abs(sprites[i]["y"] - (marioY+dy))
				if distx <= 8 and disty <= 8 then
					inputs[#inputs] = -1
				end
			end
			--Only for SNES
			for i = 1,#extended do
				distx = math.abs(extended[i]["x"] - (marioX+dx))
				disty = math.abs(extended[i]["y"] - (marioY+dy))
				if distx < 8 and disty < 8 then
					inputs[#inputs] = -1
				end
			end
		end
	end

	--mariovx = memory.read_s8(0x7B)
	--mariovy = memory.read_s8(0x7D)

	return inputs
end
