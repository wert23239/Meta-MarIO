
require "Mutations"
require "Fitness"
require "SQL"

--[[
Sigmoid: Determine if a neuron value is postive or negative
--]]
function sigmoid(x)
	return 2/(1+math.exp(-4.9*x))-1
end

--[[
newInnovation: TODO
--]]
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
	pool.maxGenerationFitness=0 --the highest fitness this generation
	pool.marioWorld=0
	pool.marioLevel=0

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
	pool.landscapeold= {}
	pool.generationAverageFitness=0 --Average Fitness this generation
	--hashtables of stats
	--key is generation value is the value at the generation
	pool.generationMaxFitnessGenome={} --Vanillia Best Fitness of this Generation per Genome
	pool.generationMaxRightmostGenome={} --Highest Rightmost Fitnes of this Generation per Genome
	pool.generationMaxNoveltyGenome={} --Highest Novelty Fitness of this Generation per Genome
	pool.generationMaxFitnessCollective={} --Vanillia Best Fitness of this Generation per Genome
	pool.generationMaxRightmostCollective={} --Highest Rightmost Fitnes of this Generation per Genome
	pool.generationMaxNoveltyCollective={} --Highest Novelty Fitness of this Generation per Genome
	pool.generationAverageRightmostGenome={} --Highest Rightmost Fitnes of this Generation per Genome
	pool.generationAverageNoveltyGenome={} --Highest Novelty Fitness of this Generation per Genome
	pool.generationAverageFitnessCollective={} --Vanillia Best Fitness of this Generation per Genome
	pool.generationAverageRightmostCollective={} --Highest Rightmost Fitnes of this Generation per Genome
	pool.generationAverageNoveltyCollective={} --Highest Novelty Fitness of this Generation per Genome
	pool.netWorld=0
	pool.netLevel=0
	pool.half=false
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
	genome.fitness = -1 --How far right an orgranism gets
	genome.rightmostFitness = 0 --Nothing
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
	genome.ran=false
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
remove: Remove species that don't do anything+
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
	local file = io.open("Fitness.csv", "a")
	local nspCount = 0
	for loc,set in pairs(pool.landscape) do
		--file:write("Location ".. loc .. "\n")
		local count=0
		for sg,value in pairs(set) do
        	count=count+1
		end
		if count<=tonumber(forms.gettext(NoveltyConstantText)) then
			nspCount = nspCount + 1
		 	for sg,value in pairs(set) do
	        	local species=math.floor(tonumber(sg)/100)
	        	local genome=tonumber(sg)%100
				--file:write("Genome " .. genome .. "\n")
				--file:write("SpeciesFitness " .. pool.species[species].genomes[genome].fitness .." Amount " .. count .. "\n")

				pool.species[species].genomes[genome].fitness=pool.species[species].genomes[genome].fitness+(tonumber((forms.gettext(NoveltyConstantText))-count)*tonumber(forms.gettext(NoveltyFitness)))
			end
		end
	end
	file:write(pool.generation ..","..tostring(nspCount).. "\n")
	console.writeline("NSP: " .. nspCount)
	file:close()
end

function GainNoveltyFitness(cordLocation)
	if pool.generation > 0 then
		local count = 0
		if pool.landscapeold[cordLocation] ~= nil then
			for sg,value in pairs(pool.landscapeold[cordLocation]) do
		       	count=count+1
			end
		end
		if count<=tonumber(forms.gettext(NoveltyConstantText)) then
			CurrentNSFitness=CurrentNSFitness+1
		end
	end
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
--]]
function newGeneration()

	if forms.ischecked(NoveltyFitness) then
		SetNoveltyFitness()
	end
	for loc,set in pairs(pool.landscape) do
		--file:write("Location ".. loc .. "\n")
		pool.landscapeold[loc]={}
		for sg,value in pairs(set) do
        	pool.landscapeold[loc][sg]=true
		end
	end
	calculateTrueAverage()
	findMaxFitnessForGeneration()
	pool.landscape={}
	RoundAmount=0
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
	resetFitness()
	pool.generation = pool.generation + 1
	UpdateGenes(CollectGenes())
	writeFile("backup." .. pool.generation .. "." .. tostring(forms.getthreadNum()) .. "." ..forms.gettext(saveLoadFile))
end

function initializeFitnessFile()
	local file = io.open("Fitness.csv", "w")
	file:write("-1" ..","..tostring(0).. "\n")
	file:close()
end

function initializePool()
	pool = newPool()
	RoundAmount=0
	initializeFitnessFile()
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
	if training then
		if RoundAmount==0 then
		savestate.load(FilenameTraining);
		elseif RoundAmount==1 then
		savestate.load(FilenameTraining2);
		else 
		savestate.load(FilenameTraining3);
		end
	elseif(memory.readbyte(0x0770)==0 or not forms.ischecked(showContinousPlay)) then
		savestate.load(Filename) --Load from a specfic savestates
	end
	rightmost = 0
	leftmost = 50000 --most change for other games
	upmost= 0
	CurrentNSFitness = 0
	pool.currentFrame = 0
	timeout =TimeoutConstant
	NetPage= memory.readbyte(0x6D)
	NetX = memory.readbyte(0x6D) * 0x100 + memory.readbyte(0x86)
	NetY= memory.readbyte(0x03B8)+16
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



function resetGenomeRan()
	for n,species in pairs(pool.species) do
		for m,genome in pairs(species.genomes) do
			genome.ran = false
		end
	end
end

--:/ you better change this 
function findMaxFitnessForGeneration()
		local generationMaxFitness=0
		local generationRightmostFitness=0
		for n,species in pairs(pool.species) do
		for m,genome in pairs(species.genomes) do
			
			if genome.rightmostFitness>generationRightmostFitness then
				generationRightmostFitness=genome.rightmostFitness
			end

			if genome.fitness>generationMaxFitness then
				generationMaxFitness=genome.fitness
			end
		end
	end
	--console.writeline(generationMaxFitnessgenerationRightmostfitness)
	--pool.generationMaxFitnessGenome[#generationMaxFitnessGenome+1]=generationMaxFitness
	--pool.generationMaxRightmostGenome[#generationMaxRightmostGenome+1]=generationRightmostfitness
end






--[[
nextGenome: Get next available genome if none start a new generation
--]]
function nextGenome(probalisticGenome,probalisticSpecies)
	result=0
	pool.currentGenome = probalisticGenome
	pool.currentSpecies = probalisticSpecies
	if GenomeAmount == Population then

		RoundAmount=RoundAmount+1
		console.writeline("Round Number ".. RoundAmount .. " Finished")
		if RoundAmount >= tonumber(forms.gettext(RoundAmountValue)) or forms.ischecked(RoundAmountFitness) == false then
				console.writeline(tonumber(RoundAmount) .. " Rounds Finished")
				newGeneration()
				result=result+1
		end
		resetGenomeRan()
		pool.currentSpecies = 1
		result=result+1
		return result
	end

	return result
end

--[[
fitnessAlreadyMesaured: Check to see if the fitness of
specfic species and genome have been mesaured.
--]]
function fitnessAlreadyMeasured()
	local species = pool.species[pool.currentSpecies]
	local genome = species.genomes[pool.currentGenome]
	return genome.ran ~= false
	--return genome.fitness ~= 0
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
	--Last one is the bias cell
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
	local j=0
	for n,cell in pairs(cells) do
		if n > Inputs or cell.value ~= 0 then
			local color = math.floor((cell.value+1)/2*256)
			if color > 255 then color = 255 end
			if color < 0 then color = 0 end
			if j> (BoxRadius*2+1)*(BoxRadius*2+1) then color=128 end
			local opacity = 0xFF000000
			if cell.value == 0 then
				opacity = 0x50000000
			end
			color = opacity + color*0x10000 + color*0x100 + color
			gui.drawBox(cell.x-2,cell.y-2,cell.x+2,cell.y+2,opacity,color)
		end
		j=j+1
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

function inPlay()
	--First Byte 747 is The Timer for Level Reset
	--Second Byte 71E is for Loading Screens
	--Third Byte 00E is Player State .. Alive,Dead,Level Animation, Flagpole
	--Last Byte is whether the play is on screen or not
	return memory.readbyte(0x0747)==0 and memory.readbyte(0x071E)~=11 and (memory.readbyte(0x000E)==8 or memory.readbyte(0x000E)==1 or memory.readbyte(0x000E)==0) and memory.readbyte(0x00B5)<=1
end


function CollectGenes()
	local GeneCollection={}
	local speciesNum=0
	local genomeNum=0
	local genomeIndividualNum=0
	local geneNum=0
	for n,species in pairs(pool.species) do
		speciesNum=speciesNum+1
		genomeIndividualNum=0
		for m,genome in pairs(species.genomes) do
			genomeNum=genomeNum+1
			genomeIndividualNum=genomeIndividualNum+1
			for l,gene in pairs(genome.genes) do
				if gene.enabled then
					geneNum=geneNum+1
					Key=speciesNum .. " " .. genomeIndividualNum .." " .. genomeNum  .. " " .. geneNum
					GeneCollection[Key]=gene.into .. " " .. gene.out .. " " .. gene.innovation
				end
			end
		end
	end
	return GeneCollection
end

function NewGenomeNumber(speciesNum,genomeNum)
	local genomeNumber={}
	genomeNumber.species=speciesNum
	genomeNumber.genome=genomeNum
	return genomeNumber
end
function NumberGenomes()
	local genomeNumber={}
	local speciesNum=0
	local genomeNum=0
	local genomeIndividualNum=0
	for n,species in pairs(pool.species) do
		speciesNum=speciesNum+1
		genomeNum=0
		for m,genome in pairs(species.genomes) do
			genomeNum=genomeNum+1
			genomeIndividualNum=genomeIndividualNum+1
			genomeNumber[genomeIndividualNum]=NewGenomeNumber(speciesNum,genomeNum)
		end
	end
	return genomeNumber
end