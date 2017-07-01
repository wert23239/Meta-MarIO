
function incrementX(Amount)
	xvalue=xvalue+Amount
	return xvalue
end

function incrementY(Amount)
	yvalue=yvalue+Amount
	return yvalue
end

--Create Fitness Form
function FitnessBox(AmountX,AmountY,BoxX,BoxY)
	yvalue=5 xvalue=5
	form = forms.newform(BoxX, BoxY, "Fitness")
	showNetwork = forms.checkbox(form, "Show Map", xvalue, yvalue, "true") --A checkbox to see whether or not the eye(inputs) and controls(outputs) is shown
	showMutationRates = forms.checkbox(form, "Show Mutate", incrementX(AmountX), yvalue)
	yvalue=incrementY(AmountY) xvalue=0
	--Label to describe the differnt types of fitness
	FitnessTypeLabel = forms.label(form, "Fitness Type:", xvalue, yvalue) --Name of fitness
	FitnessAmountLabel = forms.label(form, "Amount", incrementX(AmountX), yvalue) --How much each fitness is worth
	FitnessCheckLabel = forms.label(form, "On", incrementX(AmountX), yvalue) --Whether the fitness timeout constant can be reseted with this fitness.
	FitnessTimeoutLabel = forms.label(form, "Timeout", incrementX(AmountX), yvalue) --Enable this fitnyvaless
	yvalue=incrementY(AmountY) xvalue=0
	--Rightmost Options
	RightmostLabel = forms.label(form, "Rightmost ", xvalue, yvalue) --Rightmost Label is the fitness for how far right you can go
	RightmostAmount = forms.textbox(form, 1, 60, 20, nil, incrementX(AmountX), yvalue) --Each pixel right move is multiplied by this number
	RightmostFitness = forms.checkbox(form, "", incrementX(AmountX), yvalue, "true") --If an organism reaches farther than right than ever before during a generation reset the timeout constant
	RightmostTimeout = forms.checkbox(form, "", incrementX(AmountX), yvalue, "true")--Toggle the rightmost fitness type
	yvalue=incrementY(AmountY) xvalue=0
	--Novelty Options
	NoveltyLabel = forms.label(form, "Novelty ", xvalue, yvalue) --Novelty Label is the fitness for how unique an orgranism travels
	NoveltyAmount = forms.textbox(form, 10000, 60, 20, nil, incrementX(AmountX), yvalue)--Each spot an orgranism goes to that No more than the Novelty Constant goes to gets this many points
	NoveltyFitness = forms.checkbox(form, "", incrementX(AmountX), yvalue) --Each new place an orgranism goes resets the timeout
	NoveltyTimeout = forms.checkbox(form, "", incrementX(AmountX), yvalue, "true") --Toggle the Novelty fitness type
	yvalue=incrementY(AmountY) xvalue=0
	--Score Amount
	ScoreLabel = forms.label(form, "Score ", xvalue, yvalue)--Score Label is the fitness for how much score an organism gains during a run
	ScoreAmount = forms.textbox(form, 1, 60, 20, nil, incrementX(AmountX), yvalue)--The Score is multiplied by this number
	ScoreFitness = forms.checkbox(form, "", incrementX(AmountX), yvalue, "true") --Each time the score changes an orgranism resets there constant
	yvalue=incrementY(AmountY) xvalue=0
	-- Round Amount
	RoundLabel = forms.label(form, "Round Amount ", xvalue, yvalue)
	RoundAmountValue = forms.textbox(form, RoundAmountConstant, 60, 20, nil, incrementX(AmountX), yvalue)
	RoundAmountFitness = forms.checkbox(form, "", incrementX(AmountX), yvalue,"true")
	yvalue=incrementY(AmountY) xvalue=0
	-- Novelty and Timeout Constants
	NoveltyLabel = forms.label(form, "Novelty Const: ", xvalue, yvalue)
	NoveltyConstantText = forms.textbox(form, NoveltyConstant, 30, 20, nil, incrementX(AmountX), yvalue) --How many orgranism can visit a spot and it still be unique
	TimeoutLabel = forms.label(form, "Timeout Const: ", incrementX(AmountX), yvalue) --How many frames till an orgranism dies off if not reset by a fitness
	TimeoutConstantText = forms.textbox(form, TimeoutConstant, 30, 20, nil, incrementX(AmountX), yvalue) 
	yvalue=incrementY(AmountY) xvalue=0
	--Continous Play and Death
	showContinousPlay = forms.checkbox(form, "Continous Play", xvalue, yvalue,"true")--Play from where the last orgranism left off
	showContinousDeath = forms.checkbox(form, "Continous Death", incrementX(AmountX), yvalue)--Play from where the last orgranism left off
	showTraining = forms.checkbox(form, "Training Coming Soon", incrementX(AmountX), yvalue)--Play from where the last orgranism left off
	yvalue=incrementY(AmountY) xvalue=0
	saveButton = forms.button(form, "Save", savePool, xvalue, yvalue) --Save the Network
	loadButton = forms.button(form, "Load", loadPool, incrementX(AmountX), yvalue) --Load the Network
	restartButton = forms.button(form, "Restart", initializePool, incrementX(AmountX), yvalue) --Restart the experiment
	loadCurrentButton = forms.button(form, "Load Current", loadCurrent, incrementX(AmountX), yvalue) --Load the Network
	yvalue=incrementY(AmountY) xvalue=0
	--File Save
	saveLoadLabel = forms.label(form, "Save/Load:", xvalue, yvalue)
	saveLoadFile = forms.textbox(form, "New.pool", 110, 25, nil, incrementX(AmountX), yvalue)
	--playTopButton = forms.button(form, "Play Top", playTop, incrementX(AmountX), yvalue)
	--Hides banner
	-- hideBanner = forms.checkbox(form, "Hide Banner", incrementX(AmountX), yvalue)
	-- yvalue=incrementY(AmountY)
	-- xvalue=0
	--What you are going to name the file
end


--[[
OnExit: Exit function when you close the program
--]]
function onExit()
	forms.destroy(form)
end

