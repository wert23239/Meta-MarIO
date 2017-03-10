
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