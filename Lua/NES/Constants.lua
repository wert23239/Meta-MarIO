--[[
Setting Constants
--]]


FilenameFolder="States/"

if gameinfo.getromname() == "Super Mario World (USA)" then
	Filename = FilenameFolder.."DP1.state"
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
	Filename = FilenameFolder.."Level12.state"
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
BoxRadius: is the eye that the Organism can see.
It's where the inputs will be taken in at.
(Left side of the visual)
--]]
BoxRadius = 6
FilenameTraining = "States/t1.state"
FilenameTraining2 = "States/t2.state"
FilenameTraining3 = "States/Level12.state"
NetGeneration = 0
training = false
RoundAmountConstant = 3
RoundAmount = 0
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
Population = 25
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
MutateConnectionsChance = 0.70
PerturbChance = 0.90
CrossoverChance = 0.75
LinkMutationChance = 2.0
NodeMutationChance = 0.50
BiasMutationChance = 0.40
StepSize = 0.3
DisableMutationChance = 0.4
EnableMutationChance = 0.2

--[[
TimeoutConstant: How long it take till the enemies to despawn. Inital
--]]
TimeoutConstant = 40

--[[
MaxNodes: TODO: How many connecting nodes possible for genes
this is used so the output nodes can start at a certain number
--]]
MaxNodes = 1000000



--How many orgranisms can be on one coordinate and still get fitness
NoveltyConstant=1
CurrentNSFitness=0


--Inilizations for While Loop
--:/should be moved to species
--This determines if a species has died
TimeoutAuto=false
--This determines what happens if a species dies
NoFitness=false