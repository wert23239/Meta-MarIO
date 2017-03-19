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
loadFile: takes in a pool file and reads the contents
--]]
function loadFileMulti(filename)

    local file = io.open(filename, "r")
    --Create a new gene pool
    Population=1
	pool = newPool()

	--Read the generation
	pool.generation = 0

	--Gather MaxFitness
	pool.maxFitness = 0

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
        local numSpecies = 1
        for s=1,numSpecies do
		local species = newSpecies()
		table.insert(pool.species, species)
		species.topFitness = 0
		species.staleness = 0
		local numGenomes = 1
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
savePool: Save the pool of the saveLoadfile form
--]]
function savePool()
	local filename = forms.gettext(saveLoadFile)
	writeFile("Pools/"..filename)
end


--[[
loadPool: Button clicked to load a population
--]]
function loadPool()
	local filename = forms.gettext(saveLoadFile)
	loadFile("Pools/"..filename)
end


--[[
loadCurrent: Load current.pool
--]]
function loadCurrent()
	local filename = "current.pool"
	loadFile("Pools/"..filename)
end



--[[
writeMultiIntial: Multi-threaded intilization function
(Not Currently Used)
--]]
function writeMultiIntial(filename)
        local file = io.open(filename, "w")
        for n,species in pairs(pool.species) do
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
			file:write("end\n")
		end
        end
        file:close()
end
