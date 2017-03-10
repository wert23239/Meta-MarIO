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