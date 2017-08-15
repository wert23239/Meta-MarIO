function Open()
	emu.opendatabase()
end

function DummyRow()
	emu.writecommand([[
 	PRAGMA read_uncommitted =1;
 	insert into rewards (done) values (0);	
 	]])
end
function DummyRowDead()
	emu.writecommand([[
 	PRAGMA read_uncommitted =1;
 	insert into rewards (done) values (2);	
 	]])
end
function DummyRowEnd()
	emu.writecommand([[
 	PRAGMA read_uncommitted =1;
 	insert into rewards (done) values (3);	
 	]])
end



function EraseLastAction()
	emu.writecommand([[
		PRAGMA read_uncommitted =1; 
		delete from rewards where score is NULL;
	]])
end


function GatherGenomeNum()
	return emu.getgenome()
end

function GatherSpeciesNum()	
	return emu.getspecies() 
end

function UpdateReward(fitness_value)
	emu.writecommand([[
	PRAGMA read_uncommitted =1;
	update rewards
	set score=]] .. fitness_value .." ,status= " .. status .." WHERE score is NULL;")
	
end

function UpdateGenes(GeneCollection)
	emu.updategenetable(GeneCollection)
end

function CreateGeneTable()
	console.writeline(emu.writecommand([[
	PRAGMA read_uncommitted =1;
	CREATE TABLE Genes 
	(
		Species int(11) NOT NULL, 
		Genome int(11) NOT NULL, 
		GenomeNum int(11) NOT NULL, 
		Gene int(11) NOT NULL, 
		GeneContent varchar(100) NOT NULL, 
		PRIMARY KEY (Species, Genome, Gene)
	);]]))

end