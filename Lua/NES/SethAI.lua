-- MarI/O by SethBling
-- Feel free to use this code, but please do not redistribute it.
-- Intended for use with the BizHawk emulator and Super Mario World or Super Mario Bros. ROM.
-- For SMW, make sure you have a save state named "DP1.state" at the beginning of a level,
-- and put a copy in both the Lua folder and the root directory of BizHawk.
-- Keep this top in mind
--LoadRom("C:\\Source\\SpartaHacks17\\Super Mario Bros. (Japan, USA).nes",)


--TODO: NS reset constant
--TODO: CP reset stalefitness when worlds change 
--TODO: CP 5 rounds each genome

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
if gameinfo.getromname() == "Super Mario World (USA)" then
	Filename = "DP1.state"
	ButtonNames = {
		"A",
		"B",
		"X",
		"Y",
		"Up",
		"Down",
		"Left",
		"Right",
	}
elseif gameinfo.getromname() == "Super Mario Bros." then
	Filename = "Level11.state"
	ButtonNames = {
		"A",
		"B",
		"Up",
		"Down",
		"Left",
		"Right",
	}
end











--[[
Setting Constants
--]]

--[[
BoxRadius: is the eye that the Organism can see. 
It's where the inputs will be taken in at.
(Left side of the visual)
--]]
BoxRadius = 6


--[[
InputSize: is the amount of inputs the Organism takes in.
There is two times the amount of the box because there is two inputs
White inputs are blocks (static objects)
Black inputs are enemies (dynamic objects)
--]]
InputSize = (BoxRadius*2+1)*(BoxRadius*2+1)


--[[
Inputs : What they can see look above TODO: Why plus ones?
Outputs: These are the actions that the organims can take
That's why the only actions possible are contrller buttons
--]]
Inputs = InputSize+1
Outputs = #ButtonNames


--[[
Population: The Number of Genomes
Deltas: TODO: 
--]]
Population = 30
DeltaDisjoint = 2.0
DeltaWeights = 0.4
DeltaThreshold = 1.0



--[[
StaleSpecies: The number till a species disappears if it doesn't improve
MutateConnectionsChance: TODO:
PerturbChance: Whether or not to increase or decrease weight to 
CrossoverChance: TODO: Chance of it mating
LinkMutationChance: TODO: 
NodeMutationChance = TODO:
BiasMutationChance = TODO: 
StepSize = TODO: For Gradient Decent
DisableMutationChance = TODO: Disable Mutation
EnableMutationChance = TODO: Reenable Mutation
--]]
StaleSpecies = 15
MutateConnectionsChance = 0.25
PerturbChance = 0.90
CrossoverChance = 0.75
LinkMutationChance = 2.0
NodeMutationChance = 0.50
BiasMutationChance = 0.40
StepSize = 0.1
DisableMutationChance = 0.4
EnableMutationChance = 0.2

--[[
TimeoutConstant: How long it take till the enemies to despawn.
--]]
TimeoutConstant = 80


--[[
MaxNodes: TODO: 
--]]
MaxNodes = 1000000



--Give fitness based off of how unique the orgranism is.
--This is measured by going to each X and Y coordinate and see how rare that location is

--How many orgranisms can be on one coordinate and still get fitness
NoveltyConstant=1



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


--[[
Sigmoid: Determine if a neuron value is postive or negative
--]]
function sigmoid(x)
	return 2/(1+math.exp(-4.9*x))-1
end


function newInnovation()
	pool.innovation = pool.innovation + 1
	return pool.innovation
end


--[[
newPool Contructor: A pool is the total collection of species for all generations
Bascially a gene pool
--]]
function newPool()
	local pool = {}
	pool.species = {} --List of species
	pool.generation = 0 --Generation Number
	pool.innovation = Outputs --TODO
	pool.currentSpecies = 1 --Species Number
	pool.currentGenome = 1 -- Genome Number
	pool.currentFrame = 0 --What frame in the game currecntly at. Made-up
	pool.maxFitness = 0 --The highest fitness ever achieved.
	--List of Sets
	--Key
	--y*10,000
	--p*256
	--x*1
	--Value
	--A set with key
	--Species*100
	--Genome*1
	--Value
	--True
	--For loop through set
	--Subtract 20 - all #items in  < 20
	--Stores a dictiornary of each 
	--function Set (list)
      --local set = {}
      --for _, l in ipairs(list) do set[l] = true end
      --return set
    --end
	pool.landscape = {} 

	NetWorld=marioWorld
	NetLevel=marioLevel
	half=false
	return pool
end

--[[
newSpecies Contructor: A species is the indivual organism that evolves
--]]
function newSpecies()
	local species = {}
	species.topFitness = 0 --Max fitness of species
	species.staleness = 0 --How many generations in a row a species hasn't gotten better
	species.genomes = {} --List of all variations of a species
	species.averageFitness = 0 --Average fitnes across all genomes
	
	return species
end


--[[
newGenome Contructor: A species is the indivual organism that evolves
--]]
function newGenome()
	local genome = {} 
	genome.genes = {} --All gene which are input to output mappings
	genome.fitness = 0 --How far right an orgranism gets
	genome.adjustedFitness = 0 --Nothing
	genome.network = {} --Truth Table of all input output values
	genome.maxneuron = 0 --Number of inputs
	genome.globalRank = 0 --This is how each genomer is ranked compared to the rest of the genomes
	genome.mutationRates = {} --The differnt mutation rates.
	genome.mutationRates["connections"] = MutateConnectionsChance --
	genome.mutationRates["link"] = LinkMutationChance
	genome.mutationRates["bias"] = BiasMutationChance
	genome.mutationRates["node"] = NodeMutationChance
	genome.mutationRates["enable"] = EnableMutationChance
	genome.mutationRates["disable"] = DisableMutationChance
	genome.mutationRates["step"] = StepSize
	
	return genome
end


--[[
Genome Copy Contructor: Transfering a genome to a new species
--]]
function copyGenome(genome)
	local genome2 = newGenome()
	for g=1,#genome.genes do
		table.insert(genome2.genes, copyGene(genome.genes[g]))
	end
	genome2.maxneuron = genome.maxneuron
	genome2.mutationRates["connections"] = genome.mutationRates["connections"]
	genome2.mutationRates["link"] = genome.mutationRates["link"]
	genome2.mutationRates["bias"] = genome.mutationRates["bias"]
	genome2.mutationRates["node"] = genome.mutationRates["node"]
	genome2.mutationRates["enable"] = genome.mutationRates["enable"]
	genome2.mutationRates["disable"] = genome.mutationRates["disable"]
	
	return genome2
end

function basicGenome()
	local genome = newGenome()
	local innovation = 1

	genome.maxneuron = Inputs
	mutate(genome)
	
	return genome
end

--[[
newGene: Gene Constructor
--]]
function newGene()
	local gene = {}
	gene.into = 0
	gene.out = 0
	gene.weight = 0.0
	gene.enabled = true
	gene.innovation = 0
	
	return gene
end

--[[
copyGene: Gene Copy Constructor
--]]
function copyGene(gene)
	local gene2 = newGene()
	gene2.into = gene.into
	gene2.out = gene.out
	gene2.weight = gene.weight
	gene2.enabled = gene.enabled
	gene2.innovation = gene.innovation
	
	return gene2
end

function newNeuron()
	local neuron = {}
	neuron.incoming = {}
	neuron.value = 0.0
	
	return neuron
end

--[[
generateNetwork: Creates the input/output connection
This network will take in inputs and spit back outputs
parameter: takes in genome
--]]
function generateNetwork(genome)

	local network = {}
	network.neurons = {}
	
	--Create all the neurons needed for inputs
	for i=1,Inputs do
		network.neurons[i] = newNeuron()
	end
	

	--Create the ouput neurons after the max number of Nodes
	for o=1,Outputs do
		network.neurons[MaxNodes+o] = newNeuron()
	end
	
	--Sort genes by there output 
	table.sort(genome.genes, function (a,b)
		return (a.out < b.out)
	end)

	--Go through all the genes
	for i=1,#genome.genes do


		local gene = genome.genes[i]

		--For each gene check for enabled
		if gene.enabled then

			--Make a new neuron for a each output
			if network.neurons[gene.out] == nil then
				network.neurons[gene.out] = newNeuron()
			end
			--Gain the local output neuron
			local neuron = network.neurons[gene.out]
			--Set the incoming of the output neuron to the neuron itself
			table.insert(neuron.incoming, gene)

			--Make sure the input of the neuron exists
			if network.neurons[gene.into] == nil then
				network.neurons[gene.into] = newNeuron()
			end
		end
	end
	
	genome.network = network
end

--[[
evaluateNetwork: Figuire out the output from a network and inputs
--]]
function evaluateNetwork(network, inputs)
	table.insert(inputs, 1)

	--Assert statemtent to see if correct amount of inputs
	if #inputs ~= Inputs then
		console.writeline("Incorrect number of neural network inputs.")
		return {}
	end
	

	--Set each neuron to value of each input
	for i=1,Inputs do
		network.neurons[i].value = inputs[i]
	end
	
	--For each neuron check the 
	for _,neuron in pairs(network.neurons) do
		local sum = 0 --Find the sum
		for j = 1,#neuron.incoming do
			--Go to to all genes that connect to an output
			local incoming = neuron.incoming[j]
			
			--Find which input this connects to
			local other = network.neurons[incoming.into]

			--Calculate the total sum by dot producting the weights with the trinary value of the an input
			sum = sum + incoming.weight * other.value
		end
		
		--Change the value of a neruon by the Sum and Sigmoid
		if #neuron.incoming > 0 then
			neuron.value = sigmoid(sum)
		end
	end
	
	--Add all active outputs for a current set of inputs
	local outputs = {}
	for o=1,Outputs do
		local button = "P1 " .. ButtonNames[o]
		if network.neurons[MaxNodes+o].value > 0 then
			outputs[button] = true
		else
			outputs[button] = false
		end
	end
	
	return outputs
end

function crossover(g1, g2)
	-- Make sure g1 is the higher fitness genome
	if g2.fitness > g1.fitness then
		tempg = g1
		g1 = g2
		g2 = tempg
	end

	local child = newGenome()
	
	local innovations2 = {}
	for i=1,#g2.genes do
		local gene = g2.genes[i]
		innovations2[gene.innovation] = gene
	end
	
	for i=1,#g1.genes do
		local gene1 = g1.genes[i]
		local gene2 = innovations2[gene1.innovation]
		if gene2 ~= nil and math.random(2) == 1 and gene2.enabled then
			table.insert(child.genes, copyGene(gene2))
		else
			table.insert(child.genes, copyGene(gene1))
		end
	end
	
	child.maxneuron = math.max(g1.maxneuron,g2.maxneuron)
	
	for mutation,rate in pairs(g1.mutationRates) do
		child.mutationRates[mutation] = rate
	end
	
	return child
end

--[[
randomNeuron: 
(Genes):List of genes from a genome
(nonInput): bool for whether the gene is an input or not
Find a random neuron from a list of genes
--]]
function randomNeuron(genes, nonInput)
	local neurons = {}
	if not nonInput then --Add inputs to the randomneruon chance
		for i=1,Inputs do
			neurons[i] = true
		end
	end
	for o=1,Outputs do --Add outputs to randomnueron chance
		neurons[MaxNodes+o] = true
	end
	for i=1,#genes do
		if (not nonInput) or genes[i].into > Inputs then --Add in seperate gene inputs
			neurons[genes[i].into] = true
		end
		if (not nonInput) or genes[i].out > Inputs then --Add in seperate gene outputs
			neurons[genes[i].out] = true
		end
	end

	local count = 0
	for _,_ in pairs(neurons) do
		count = count + 1
	end --Count how many genomes they currently are
	local n = math.random(1, count) --generate random number in between these neurons
	
	for k,v in pairs(neurons) do
		n = n-1 --keep decreasing the genomes till the 2
		if n == 0 then
			return k
		end
	end
	
	return 0
end

--[[
contains link: 
(genes): all genes for a genome
(link): the current new link
see if a link already exist before adding it 
--]]
function containsLink(genes, link)
	for i=1,#genes do
		local gene = genes[i]
		if gene.into == link.into and gene.out == link.out then
			return true
		end
	end
end


--[[
pointMutate: Connections Mutation rate for each Gene change the weight for mutation
--]]
function pointMutate(genome)
	local step = genome.mutationRates["step"]
	
	for i=1,#genome.genes do
		local gene = genome.genes[i]
		if math.random() < PerturbChance then
			gene.weight = gene.weight + math.random() * step*2 - step --increase weight by step size
		else
			gene.weight = math.random()*4-2  --redo mutation
		end
	end
end


--[[
linkMutate: Link and Bias mutation use this 
Gather two genomes and set one as input on as ouptut in a new gene
--]]
function linkMutate(genome, forceBias)
	local neuron1 = randomNeuron(genome.genes, false) --Gain one nueron that might be anything
	local neuron2 = randomNeuron(genome.genes, true) --Gain one input that can be anything
	 
	local newLink = newGene()  --Create a new gene
	if neuron1 <= Inputs and neuron2 <= Inputs then
		--Both input nodes
		return
	end
	if neuron2 <= Inputs then --neuron 2 has to be output
		-- Swap output and input
		local temp = neuron1
		neuron1 = neuron2
		neuron2 = temp
	end

	newLink.into = neuron1
	newLink.out = neuron2
	if forceBias then --if link function then make inputs vanilla
		newLink.into = Inputs
	end
	
	--Makes sure link isn't already there
	if containsLink(genome.genes, newLink) then
		return
	end
	newLink.innovation = newInnovation() 
	newLink.weight = math.random()*4-2 --determine weight of the new gene
	
	table.insert(genome.genes, newLink)
end

--[[
nodeMutate: Link and Bias mutation use this 
--]]
function nodeMutate(genome)

	--make sure at least one genome exists
	if #genome.genes == 0 then
		return
	end

	--increase the max neruon count to accomndate new neuron
	genome.maxneuron = genome.maxneuron + 1

	--gain a random gene in a list of genes from a genome
	local gene = genome.genes[math.random(1,#genome.genes)]
	if not gene.enabled then
		return
	end

	--disable gene
	gene.enabled = false
	
	--Copy gene and set it output to the end
	local gene1 = copyGene(gene)
	gene1.out = genome.maxneuron
	gene1.weight = 1.0
	gene1.innovation = newInnovation()
	gene1.enabled = true
	table.insert(genome.genes, gene1)
	
	--Copy gene and set its input to the end
	local gene2 = copyGene(gene)
	gene2.into = genome.maxneuron
	gene2.innovation = newInnovation()
	gene2.enabled = true
	table.insert(genome.genes, gene2)
end

--[[
enableDisableMutate: Goes through each genome and changes one to enable/diable depnding on the boolean
--]]
function enableDisableMutate(genome, enable)
	local candidates = {}
	for _,gene in pairs(genome.genes) do
		if gene.enabled == not enable then
			table.insert(candidates, gene)
		end
	end
	
	if #candidates == 0 then
		return
	end
	
	local gene = candidates[math.random(1,#candidates)] --random vaiable input/output
	gene.enabled = not gene.enabled --set gene to the oppsite genome
end


--[[
mutate: Randomly try differnt types of mutuations of a genome
--]]
function mutate(genome)
	for mutation,rate in pairs(genome.mutationRates) do
		--Randomly increase and decrese all types of mutations
		if math.random(1,2) == 1 then
			genome.mutationRates[mutation] = 0.95*rate
		else
			genome.mutationRates[mutation] = 1.05263*rate
		end
	end

	--See if the connection rate is higher than random 0 to 1
	if math.random() < genome.mutationRates["connections"] then
		pointMutate(genome) --Mutate all Gene Rates
	end
	
	--Add Gene links over and over again until p without forced bias
	local p = genome.mutationRates["link"]
	while p > 0 do 
		if math.random() < p then
			linkMutate(genome, false)
		end
		p = p - 1
	end
	
	--Add Gene links over and over again until p is below 0 set at true
	p = genome.mutationRates["bias"]
	while p > 0 do
		if math.random() < p then
			linkMutate(genome, true)
		end
		p = p - 1
	end
	
	--Node muatation chance over and over 
	p = genome.mutationRates["node"]
	while p > 0 do
		if math.random() < p then
			nodeMutate(genome)
		end
		p = p - 1
	end
	
	--Enable random genes
	p = genome.mutationRates["enable"]
	while p > 0 do
		if math.random() < p then
			enableDisableMutate(genome, true)
		end
		p = p - 1
	end

	--Disable random genes
	p = genome.mutationRates["disable"]
	while p > 0 do
		if math.random() < p then
			enableDisableMutate(genome, false)
		end
		p = p - 1
	end
end

function disjoint(genes1, genes2)
	local i1 = {}
	for i = 1,#genes1 do
		local gene = genes1[i]
		i1[gene.innovation] = true
	end

	local i2 = {}
	for i = 1,#genes2 do
		local gene = genes2[i]
		i2[gene.innovation] = true
	end
	
	local disjointGenes = 0
	for i = 1,#genes1 do
		local gene = genes1[i]
		if not i2[gene.innovation] then
			disjointGenes = disjointGenes+1
		end
	end
	
	for i = 1,#genes2 do
		local gene = genes2[i]
		if not i1[gene.innovation] then
			disjointGenes = disjointGenes+1
		end
	end
	
	local n = math.max(#genes1, #genes2)
	
	return disjointGenes / n
end

function weights(genes1, genes2)
	local i2 = {}
	for i = 1,#genes2 do
		local gene = genes2[i]
		i2[gene.innovation] = gene
	end

	local sum = 0
	local coincident = 0
	for i = 1,#genes1 do
		local gene = genes1[i]
		if i2[gene.innovation] ~= nil then
			local gene2 = i2[gene.innovation]
			sum = sum + math.abs(gene.weight - gene2.weight)
			coincident = coincident + 1
		end
	end
	
	return sum / coincident
end
	
function sameSpecies(genome1, genome2)
	local dd = DeltaDisjoint*disjoint(genome1.genes, genome2.genes)
	local dw = DeltaWeights*weights(genome1.genes, genome2.genes) 
	return dd + dw < DeltaThreshold
end

--[[
rankGlobally: rank all the genomes to see which has the highest fitness
Higher number rank means higher fitness
--]]
function rankGlobally()
	local global = {}
	for s = 1,#pool.species do
		local species = pool.species[s]
		for g = 1,#species.genomes do
			table.insert(global, species.genomes[g])
		end
	end
	table.sort(global, function (a,b)
		return (a.fitness < b.fitness)
	end)
	
	for g=1,#global do
		global[g].globalRank = g
	end
end

--[[
calculateAverageFitness: This average is the global rank added up divided by the number of genomes
(species): the current species being evaulated
--]]
function calculateAverageFitness(species)
	local total = 0
	
	for g=1,#species.genomes do
		local genome = species.genomes[g]
		total = total + genome.globalRank
	end
	
	species.averageFitness = total / #species.genomes
end

--[[
totalAverageFitness: Go through all species and add up the total average fitness per species
This average fitness is the global rank of all the genomes divided by the number of genomes not actual fitness
--]]
function totalAverageFitness()
	local total = 0
	for s = 1,#pool.species do
		local species = pool.species[s]
		total = total + species.averageFitness
	end

	return total
end

--[[
cullSpecies: 
(cutToOne):
(False) Removes lowest half of the genomes that have the lowest fitness for a given species.
(True) Only allows one genome to remain in a specific species.
--]]
function cullSpecies(cutToOne)
	for s = 1,#pool.species do
		local species = pool.species[s]
		
		table.sort(species.genomes, function (a,b)
			return (a.fitness > b.fitness)
		end)
		
		local remaining = math.ceil(#species.genomes/2)
		if cutToOne then
			remaining = 1
		end
		while #species.genomes > remaining do
			table.remove(species.genomes)
		end
	end
end

function breedChild(species)
	local child = {}
	if math.random() < CrossoverChance then
		g1 = species.genomes[math.random(1, #species.genomes)]
		g2 = species.genomes[math.random(1, #species.genomes)]
		child = crossover(g1, g2)
	else
		g = species.genomes[math.random(1, #species.genomes)]
		child = copyGenome(g)
	end
	
	mutate(child)
	
	return child
end

--[[
removeStaleSpecies: Remove species that don't do anything+
--]]
function removeStaleSpecies()
	local survived = {}

	--Go through alll species
	for s = 1,#pool.species do 
		local species = pool.species[s]
		

		--Sort genomes by fitness
		table.sort(species.genomes, function (a,b)
			return (a.fitness > b.fitness)
		end)
		
		--Pick the top genome and see if it's higher then the current species
		if species.genomes[1].fitness > species.topFitness then
			species.topFitness = species.genomes[1].fitness --Set the fitness to the next top
			species.staleness = 0 --Staleness is reset
		else
			species.staleness = species.staleness + 1 --Counts up by one each time
		end

		--If a species is below the Stale constant or is the maxfiness keep it.
		if species.staleness < StaleSpecies or species.topFitness >= pool.maxFitness then
			table.insert(survived, species)
		end
	end

	pool.species = survived --Set the species to only the survivors
end

--[[
SetNoveltyFitness: Goes through all mario's and sets there fitness to whatever unqiue spots they have been
--]]
function SetNoveltyFitness()
	--local file = io.open("Fitness.pool", "w") 
	for loc,set in pairs(pool.landscape) do 
		--file:write("Location ".. loc .. "\n")
		local count=0
		for sg,value in pairs(set) do
        	count=count+1
		end
		if count<=tonumber(forms.gettext(NoveltyConstantText)) then
		 	for sg,value in pairs(set) do
	        	local species=math.floor(tonumber(sg)/100)
	        	local genome=tonumber(sg)%100
				--file:write("Species " .. species .. "\n")
				--file:write("Genome " .. genome .. "\n")
				--file:write("SpeciesFitness " .. pool.species[species].genomes[genome].fitness .." Amount " .. count .. "\n")
				console.writeline("Loc" .. loc)
				pool.species[species].genomes[genome].fitness=pool.species[species].genomes[genome].fitness+(tonumber((forms.gettext(NoveltyConstantText))-count)*10000) 
			end
		end
	end
	--file:close()
end

--[[
removeWeakSpecies: 
--]]
function removeWeakSpecies()
	local survived = {}

	--gather total rank of all species
	local sum = totalAverageFitness()

	--divide each species by total rank and times by population
	--Strange formula :/
	for s = 1,#pool.species do
		local species = pool.species[s]
		breed = math.floor(species.averageFitness / sum * Population)

		--If population is above 1 then keep it
		if breed >= 1 then
			table.insert(survived, species)
		end
	end

	pool.species = survived
end

function addToSpecies(child)
	local foundSpecies = false
	for s=1,#pool.species do
		local species = pool.species[s]
		if not foundSpecies and sameSpecies(child, species.genomes[1]) then
			table.insert(species.genomes, child)
			foundSpecies = true
		end
	end
	
	if not foundSpecies then
		local childSpecies = newSpecies()
		table.insert(childSpecies.genomes, child)
		table.insert(pool.species, childSpecies)
	end
end

--[[
newGeneration: Each time you go through all of the species a new generation will start
This does the following:
-Removes uneffective genomes with(cullSpecies,removeStaleSpecies,removeWeakSpecies)
-
-
-
-
-
-
--]]
function newGeneration()
	if forms.ischecked(NoveltyFitness) then
		SetNoveltyFitness()
	end
	pool.landscape={}
	cullSpecies(false) -- Cull the bottom half of each species (The only comment written by SethBling in the entire code set)
	rankGlobally() --rank all genomes by fitness order
	removeStaleSpecies() --removes species who haven't improved in a while
	rankGlobally() --re-rank

	--Calculate Fitness for all species
	for s = 1,#pool.species do  
		local species = pool.species[s]
		calculateAverageFitness(species)
	end
	removeWeakSpecies() 
	local sum = totalAverageFitness()
	local children = {}
	for s = 1,#pool.species do
		local species = pool.species[s]
		breed = math.floor(species.averageFitness / sum * Population) - 1
		for i=1,breed do
			table.insert(children, breedChild(species))
		end
	end
	cullSpecies(true) -- Cull all but the top member of each species
	while #children + #pool.species < Population do
		local species = pool.species[math.random(1, #pool.species)]
		table.insert(children, breedChild(species))
	end
	for c=1,#children do
		local child = children[c]
		addToSpecies(child)
	end
	
	pool.generation = pool.generation + 1
	
	writeFile("backup." .. pool.generation .. "." .. forms.gettext(saveLoadFile))
end
	
function initializePool()
	pool = newPool()

	for i=1,Population do
		basic = basicGenome()
		addToSpecies(basic)
	end

	initializeRun()
end

function clearJoypad()
	controller = {}
	for b = 1,#ButtonNames do
		controller["P1 " .. ButtonNames[b]] = false
	end
	joypad.set(controller)
end


--[[
initalizeRun: Before a new orgranism starts
--]]
function initializeRun()
	if(memory.readbyte(0x0770)==0 or not forms.ischecked(showContinousPlay)) then
		savestate.load(Filename); --Load from a specfic savestates
	end
	rightmost = 0
	pool.currentFrame = 0
	timeout =TimeoutConstant
	NetX = memory.readbyte(0x6D) * 0x100 + memory.readbyte(0x86)
	NetScore = memory.readbyte(0x07D8)*100000+memory.readbyte(0x07D9)*10000+memory.readbyte(0x07DA)*1000
	NetScore = NetScore + memory.readbyte(0x07DB)*100 + memory.readbyte(0x07DC)*10 + memory.readbyte(0x07DC)*1
	clearJoypad()
	
	local species = pool.species[pool.currentSpecies]
	local genome = species.genomes[pool.currentGenome]
	generateNetwork(genome)
	evaluateCurrent()
end


--[[
evaluateCurrent: Figuire out which controller buttons to press
--]]
function evaluateCurrent()
	local species = pool.species[pool.currentSpecies]
	local genome = species.genomes[pool.currentGenome]


	inputs = getInputs()

	controller = evaluateNetwork(genome.network, inputs)
	

	--Stop P1 Left and P1 Right from being pressed at the same time
	if controller["P1 Left"] and controller["P1 Right"] then
		controller["P1 Left"] = false
		controller["P1 Right"] = false
	end
	--Stop Pl Up and P1 Down from being pressed at the same time
	if controller["P1 Up"] and controller["P1 Down"] then
		controller["P1 Up"] = false
		controller["P1 Down"] = false
	end

	joypad.set(controller)
end

if pool == nil then
	initializePool()
end


--[[
nextGenome: Get next available genome if none start a new generation
--]]
function nextGenome()
	pool.currentGenome = pool.currentGenome + 1

	if pool.currentGenome > #pool.species[pool.currentSpecies].genomes then
		pool.currentGenome = 1
		pool.currentSpecies = pool.currentSpecies+1
		if pool.currentSpecies > #pool.species then
			newGeneration()
			pool.currentSpecies = 1
		end
	end
end

--[[
fitnessAlreadyMesaured: Check to see if the fitness of 
specfic species and genome have been mesaured.
--]]
function fitnessAlreadyMeasured()
	local species = pool.species[pool.currentSpecies]
	local genome = species.genomes[pool.currentGenome]
	
	return genome.fitness ~= 0
end



function displayGenome(genome)
	local network = genome.network
	local cells = {}
	local i = 1
	local cell = {}
	for dy=-BoxRadius,BoxRadius do
		for dx=-BoxRadius,BoxRadius do
			cell = {}
			cell.x = 50+5*dx
			cell.y = 70+5*dy
			cell.value = network.neurons[i].value
			cells[i] = cell
			i = i + 1
		end
	end
	local biasCell = {}
	biasCell.x = 80
	biasCell.y = 110
	biasCell.value = network.neurons[Inputs].value
	cells[Inputs] = biasCell
	
	for o = 1,Outputs do
		cell = {}
		cell.x = 220
		cell.y = 30 + 8 * o
		cell.value = network.neurons[MaxNodes + o].value
		cells[MaxNodes+o] = cell
		local color
		if cell.value > 0 then
			color = 0xFF0000FF
		else
			color = 0xFF000000
		end
		gui.drawText(223, 24+8*o, ButtonNames[o], color, 9)
	end
	
	for n,neuron in pairs(network.neurons) do
		cell = {}
		if n > Inputs and n <= MaxNodes then
			cell.x = 140
			cell.y = 40
			cell.value = neuron.value
			cells[n] = cell
		end
	end
	
	for n=1,4 do
		for _,gene in pairs(genome.genes) do
			if gene.enabled then
				local c1 = cells[gene.into]
				local c2 = cells[gene.out]
				if gene.into > Inputs and gene.into <= MaxNodes then
					c1.x = 0.75*c1.x + 0.25*c2.x
					if c1.x >= c2.x then
						c1.x = c1.x - 40
					end
					if c1.x < 90 then
						c1.x = 90
					end
					
					if c1.x > 220 then
						c1.x = 220
					end
					c1.y = 0.75*c1.y + 0.25*c2.y
					
				end
				if gene.out > Inputs and gene.out <= MaxNodes then
					c2.x = 0.25*c1.x + 0.75*c2.x
					if c1.x >= c2.x then
						c2.x = c2.x + 40
					end
					if c2.x < 90 then
						c2.x = 90
					end
					if c2.x > 220 then
						c2.x = 220
					end
					c2.y = 0.25*c1.y + 0.75*c2.y
				end
			end
		end
	end
	
	gui.drawBox(50-BoxRadius*5-3,70-BoxRadius*5-3,50+BoxRadius*5+2,70+BoxRadius*5+2,0xFF000000, 0x80808080)
	for n,cell in pairs(cells) do
		if n > Inputs or cell.value ~= 0 then
			local color = math.floor((cell.value+1)/2*256)
			if color > 255 then color = 255 end
			if color < 0 then color = 0 end
			local opacity = 0xFF000000
			if cell.value == 0 then
				opacity = 0x50000000
			end
			color = opacity + color*0x10000 + color*0x100 + color
			gui.drawBox(cell.x-2,cell.y-2,cell.x+2,cell.y+2,opacity,color)
		end
	end
	for _,gene in pairs(genome.genes) do
		if gene.enabled then
			local c1 = cells[gene.into]
			local c2 = cells[gene.out]
			local opacity = 0xA0000000
			if c1.value == 0 then
				opacity = 0x20000000
			end
			
			local color = 0x80-math.floor(math.abs(sigmoid(gene.weight))*0x80)
			if gene.weight > 0 then 
				color = opacity + 0x8000 + 0x10000*color
			else
				color = opacity + 0x800000 + 0x100*color
			end
			gui.drawLine(c1.x+1, c1.y, c2.x-3, c2.y, color)
		end
	end
	
	gui.drawBox(49,71,51,78,0x00000000,0x80FF0000)
	
	if forms.ischecked(showMutationRates) then
		local pos = 100
		for mutation,rate in pairs(genome.mutationRates) do
			gui.drawText(100, pos, mutation .. ": " .. rate, 0xFF000000, 10)
			pos = pos + 8
		end
	end
end

--[[
writeFile: See loadFile for specifics
--]]
function writeFile(filename)
        local file = io.open(filename, "w")
	file:write(pool.generation .. "\n")
	file:write(pool.maxFitness .. "\n")
	file:write(#pool.species .. "\n")
        for n,species in pairs(pool.species) do
		file:write(species.topFitness .. "\n")
		file:write(species.staleness .. "\n")
		file:write(#species.genomes .. "\n")
		for m,genome in pairs(species.genomes) do
			file:write(genome.fitness .. "\n")
			file:write(genome.maxneuron .. "\n")
			for mutation,rate in pairs(genome.mutationRates) do
				file:write(mutation .. "\n")
				file:write(rate .. "\n")
			end
			file:write("done\n")
			
			file:write(#genome.genes .. "\n")
			for l,gene in pairs(genome.genes) do
				file:write(gene.into .. " ")
				file:write(gene.out .. " ")
				file:write(gene.weight .. " ")
				file:write(gene.innovation .. " ")
				if(gene.enabled) then
					file:write("1\n")
				else
					file:write("0\n")
				end
			end
		end
        end
        file:close()
end

function savePool()
	local filename = forms.gettext(saveLoadFile)
	writeFile(filename)
end

--[[
loadFile: takes in a pool file and reads the contents
--]]
function loadFile(filename)

    local file = io.open(filename, "r")
    --Create a new gene pool
	pool = newPool()

	--Read the generation
	pool.generation = file:read("*number")

	--Gather MaxFitness
	pool.maxFitness = file:read("*number")

	forms.settext(maxFitnessLabel, "Max Fitness: " .. math.floor(pool.maxFitness))

		--Read the file
		--[[
		1 Line: Generation
		2 Line: Max Fitness
		3 Line: Number of Species
		4 Line: Top Fitness for Species
		5 Line: How Stale the species is
		6 Line: Number of Genomes
		7 Line: Top Fitness for set of genomes
		8 Line: TODO: Max Neuron
		9-23 Line: Set up diffent rates
		24 Line: Number of Genes
		For each gene 25- Number of Genes
		2*.1 Line: Into Gene
		2*.2 Line: Out Gene
		2*.3 Line: Weight Gene
		2*.4 Line: Innovation Gene
		2*.5 Line: Enabled Boolean
		Into Gene: What inputs need to be on the screen to run this
		Out Gene: What controller output to execute
		Weight Gene: How much the gene mattters
		Inovation: TODO:
		Enabled Gene: Determine whether to use the gene
		--]]
        local numSpecies = file:read("*number")
        for s=1,numSpecies do
		local species = newSpecies()
		table.insert(pool.species, species)
		species.topFitness = file:read("*number")
		species.staleness = file:read("*number")
		local numGenomes = file:read("*number")
		for g=1,numGenomes do
			local genome = newGenome()
			table.insert(species.genomes, genome)
			genome.fitness = file:read("*number")
			genome.maxneuron = file:read("*number")
			local line = file:read("*line")
			while line ~= "done" do
				genome.mutationRates[line] = file:read("*number")
				line = file:read("*line")
			end
			local numGenes = file:read("*number")
			for n=1,numGenes do
				local gene = newGene()
				table.insert(genome.genes, gene)
				local enabled
				gene.into, gene.out, gene.weight, gene.innovation, enabled = file:read("*number", "*number", "*number", "*number", "*number")
				if enabled == 0 then
					gene.enabled = false
				else
					gene.enabled = true
				end
				
			end
		end
	end
        file:close()
	
	while fitnessAlreadyMeasured() do
		nextGenome()
	end
	initializeRun()
	pool.currentFrame = pool.currentFrame + 1
end
 
 --[[
loadPool: Button clicked to load a population 
--]]
function loadPool()
	local filename = forms.gettext(saveLoadFile)
	loadFile(filename)
end

--[[
playTop: Plays the orgranism with the top fitness
--]]
function playTop()
	local maxfitness = 0
	local maxs, maxg
	for s,species in pairs(pool.species) do
		for g,genome in pairs(species.genomes) do
			if genome.fitness > maxfitness then
				maxfitness = genome.fitness
				maxs = s
				maxg = g
			end
		end
	end
	
	pool.currentSpecies = maxs
	pool.currentGenome = maxg
	pool.maxFitness = maxfitness
	forms.settext(maxFitnessLabel, "Max Fitness: " .. math.floor(pool.maxFitness))
	initializeRun()
	pool.currentFrame = pool.currentFrame + 1
	return
end

--[[
OnExit: Exit function when you close the program
--]]
function onExit()
	forms.destroy(form)
end

function inPlay()	
	--First Byte 747 is The Timer for Level Reset
	--Second Byte 71E is for Loading Screens
	--Third Byte 00E is Player State .. Alive,Dead,Level Animation, Flagpole
	--Last Byte is whether the play is on screen or not
	return memory.readbyte(0x0747)==0 and memory.readbyte(0x071E)~=11 and (memory.readbyte(0x000E)==8 or memory.readbyte(0x000E)==1 or memory.readbyte(0x000E)==0) and memory.readbyte(0x00B5)<=1
end

function LevelChangeHalfway()
	if memory.readbyte(0x071E)==11 and memory.readbyte(0x0728)~=0 and half==false then
		half = true
		Filename = "Level" .. NetWorld+1 .. NetLevel+1 .. 5 ..".state"
		console.writeline("Next Level Half")
		--resetStaleFitness
	end 	
end

function LevelChange()
	if NetLevel~=marioLevel or NetWorld~=marioWorld then
		NetWorld=marioWorld
		NetLevel=marioLevel
		half=false
		Filename = "Level" .. NetWorld+1 .. NetLevel+1 .. ".state"
		console.writeline("Next Level")
		--resetStaleFitness
	end	
end
function CalculateLocationCord()	
	--console.writeline("X ".. memory.readbyte(0x86).. " Page " .. memory.readbyte(0x6D) .. " Y " .. marioY )
	--console.writeline( math.floor(marioY/16)*10000+memory.readbyte(0x6D) * 1000  + math.floor(memory.readbyte(0x86)/16) )
	return math.floor(marioY/16)*10000+memory.readbyte(0x6D) * 1000 + math.floor(memory.readbyte(0x86)/16)
end

function CalculateSpeciesCord(species,genome)
	return species*100+genome
end

-- function CheckLandscape(cordLocation,cordSpecies)
-- 	if pool.landscape[tostring(cordLocation)]=nil then
-- 		console.writeline("new")
-- 	end
-- end

writeFile("temp.pool")

--makes the OnExit function work onExit
event.onexit(onExit)


--Create Fitness Form
form = forms.newform(340, 280, "Fitness")
--MaxFitness is the current Max
maxFitnessLabel = forms.label(form, "Max Fitness: " .. math.floor(pool.maxFitness), 5, 8)
--Checkbox are bools used in the infinite while loop


--A checkbox to see the Mutation rates
showMutationRates = forms.checkbox(form, "Show Mutate", 230, 3)

--A checkbox to see whether or not the eye(inputs) and controls(outputs) is shown
showNetwork = forms.checkbox(form, "Show Map", 120, 3)

--Label to describe the differnt types of fitness

--Name of fitness
FitnessTypeLabel = forms.label(form, "Fitness Type:", 5, 30)
--How much each fitness is worth
FitnessAmountLabel = forms.label(form, "Amount", 117, 30)
--Whether the fitness timeout constant can be reseted with this fitness.
--The Fitness type DOESn't have to be on.
FitnessTimeoutLabel = forms.label(form, "Timeout", 270, 30)
--Enable this fitness
FitnessCheckLabel = forms.label(form, "On", 230, 30)

--Rightmost Label is the fitness for how far right you can go
RightmostLabel = forms.label(form, "Rightmost ", 5, 55)
--Each pixel right move is multiplied by this number
RightmostAmount = forms.textbox(form, 1, 60, 20, nil, 120, 55)
--If an organism reaches farther than right than ever before during a generation reset the timeout constant
RightmostTimeout = forms.checkbox(form, "", 270, 55)
--Toggle the rightmost fitness type
RightmostFitness = forms.checkbox(form, "", 230, 55)

--Novelty Label is the fitness for how unique an orgranism travels
NoveltyLabel = forms.label(form, "Novelty ", 5, 80)
--Each spot an orgranism goes to that No more than the Novelty Constant goes to gets this many points 
NoveltyAmount = forms.textbox(form, 10000, 60, 20, nil, 120, 80)
--Each new place an orgranism goes resets the timeout
NoveltyTimeout = forms.checkbox(form, "", 270, 80)
--Toggle the Novelty fitness type
NoveltyFitness = forms.checkbox(form, "", 230, 80)

--Score Label is the fitness for how much score an organism gains during a run
ScoreLabel = forms.label(form, "Score ", 5, 105)
--The Score is multiplied by this number
ScoreAmount = forms.textbox(form, 1, 60, 20, nil, 120, 105)
--Each time the score changes an orgranism resets there constant
--ScoreTimeout = forms.checkbox(form, "", 270, 105)
--Toggle the Score fitness type
ScoreFitness = forms.checkbox(form, "", 230, 105)

--How many orgranism can visit a spot and it still be unique
NoveltyConstantText = forms.textbox(form, NoveltyConstant, 30, 20, nil, 270, 130)
NoveltyLabel = forms.label(form, "Novelty Constant: ", 170, 130)
--How many frames till an orgranism dies off if not reset by a fitness
TimeoutConstantText = forms.textbox(form, TimeoutConstant, 30, 20, nil, 120, 130)
TimeoutLabel = forms.label(form, "Timeout Constant: ", 5, 130)

--Play from the beginning each time but if you reach a check point or level end change the start location to this
--showDeterminedContinousPlay = forms.checkbox(form, "Determine Play", 120, 150)
--Play from where the last orgranism left off
showContinousPlay = forms.checkbox(form, "Continous Play", 5, 150)


--Save the Network
saveButton = forms.button(form, "Save", savePool, 5, 175)
--Load the Network
loadButton = forms.button(form, "Load", loadPool, 80, 175)
--Restart the experiment
restartButton = forms.button(form, "Restart", initializePool, 75+80, 175)

--Calls PlayTop function
playTopButton = forms.button(form, "Play Top", playTop, 75+75+80, 175)


--Hides banner
hideBanner = forms.checkbox(form, "Hide Banner", 210, 210)

--What you are going to name the file
saveLoadFile = forms.textbox(form, Filename .. ".pool", 110, 25, nil, 80, 210)
saveLoadLabel = forms.label(form, "Save/Load:", 5, 210)


TimeoutAuto=false

--Infinte Fitness Loop
while true do
	--Sets the Top Bar Color
	local backgroundColor = 0xD0FFFFFF
	--client.SetGameExtraPadding(pool.generation,0,0,0); 
	--Draws the Top Box
	if not forms.ischecked(hideBanner) then
 		gui.drawBox(0, 0, 300, 40, backgroundColor, backgroundColor)
	end


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

		--Sets Each Point a 
		if forms.ischecked(NoveltyFitness) or forms.ischecked(NoveltyTimeout) then
			if pool.currentFrame%10 == 0 then
				--Populate Cordinates
				local cordLocation=CalculateLocationCord() --y/16*10000+page*1000+x/16*1
				local cordSpecies=CalculateSpeciesCord(pool.currentSpecies,pool.currentGenome) --speices*100+genome*1	

				if pool.landscape[tostring(cordLocation)]==nil then
					pool.landscape[tostring(cordLocation)]={}
				end

				if not pool.landscape[tostring(cordLocation)][tostring(cordSpecies)]==true then
					pool.landscape[tostring(cordLocation)][tostring(cordSpecies)]=true
					if forms.ischecked(NoveltyTimeout) then
						timeout = tonumber(forms.gettext(TimeoutConstantText))
					end
				end

			end
		end
		--If mario reached more right than before reset his time to the constant
		if marioX > rightmost and ( forms.ischecked(RightmostFitness) or forms.ischecked(RightmostTimeout)  )then
			rightmost = marioX
			if forms.ischecked(RightmostTimeout) then
				timeout = tonumber(forms.gettext(TimeoutConstantText))
			end
		end
		

		--Subtract one time unit each loop
		timeout = timeout - 1
		
		
		--Each extra four frames give mario and extra bonus living amount
		local timeoutBonus = pool.currentFrame / 4

		--If the orgranism has not evolved within the allotted time end the run
		if timeout + timeoutBonus <= 0  or TimeoutAuto == true then
			TimeoutAuto=false
			local fitness=0
			--fitness equal how right subtracted from how long it takes
			if forms.ischecked(RightmostFitness) then
				fitness = tonumber(forms.gettext(RightmostAmount))*(rightmost - NetX)
			end
			if forms.ischecked(ScoreFitness) then
				fitness = fitness+tonumber(forms.gettext(ScoreAmount))*(marioScore - NetScore)
			end
			if forms.ischecked(NoveltyFitness) then
				fitness = fitness + 0
			end
			--Extra bonus for completeting the level
			if gameinfo.getromname() == "Super Mario World (USA)" and rightmost > 4816 then
				fitness = fitness + 1000
			end
			if gameinfo.getromname() == "Super Mario Bros." and rightmost > 3186 then
				fitness = fitness + 1000
			end

			--Mark it is done
			if fitness == 0 then
				fitness = -1
			end

			--Set the current genomes fitness to the local fitness
			genome.fitness = fitness
			
			--If newfitness record then 
			if fitness > pool.maxFitness then
				--Set the MaxFitness for the gene pool
				pool.maxFitness = fitness
				--Set the top text to the new fitness
				forms.settext(maxFitnessLabel, "Max Fitness: " .. math.floor(pool.maxFitness))
				--Create a backup
				writeFile("backup." .. pool.generation .. "." .. forms.gettext(saveLoadFile))
			end
			
			console.writeline("Gen " .. pool.generation .. " species " .. pool.currentSpecies .. " genome " .. pool.currentGenome .. " fitness: " .. fitness)
			console.writeline("World " .. marioWorld .. " Level " .. marioLevel)
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
		local fitnessDisplay = 0
		if forms.ischecked(RightmostFitness) then
				fitnessDisplay = (rightmost - NetX)*tonumber(forms.gettext(RightmostAmount))
		end	
		
		if forms.ischecked(ScoreFitness) then
				fitnessDisplay = fitnessDisplay+tonumber(forms.gettext(ScoreAmount))*(marioScore - NetScore)
		end	
		if not forms.ischecked(hideBanner) then
			gui.drawText(0, 12, "Gen " .. pool.generation .. " species " .. pool.currentSpecies .. " genome " .. pool.currentGenome .. " (" .. math.floor(measured/total*100) .. "%)", 0xFF000000, 11)
			gui.drawText(0, 24, "Fitness: " .. math.floor(fitnessDisplay), 0xFF000000, 11)
			gui.drawText(100, 24, "Max Fitness: " .. math.floor(pool.maxFitness), 0xFF000000, 11)
		end
	--Manual Update of Frame 	
	pool.currentFrame = pool.currentFrame + 1
	else
		getPositions()
		LevelChange()
		LevelChangeHalfway()
		if memory.readbyte(0x071E)==11 then
			TimeoutAuto=true
		end
		
	end
	

	--Actual Update of Frame
	emu.frameadvance();
end