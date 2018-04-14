function Open()
	if tonumber(forms.getthreadNum())==0 then
		emu.opendatabase()
	end
end

function DummyRow()
	if tonumber(forms.getthreadNum())==0 then
		emu.writecommand([[
	 	PRAGMA read_uncommitted =1;
	 	insert into rewards (done) values (0);	
	 	]])
	end
end

function DummyRowLoad()
	if tonumber(forms.getthreadNum())==0 then
		emu.writecommand([[
	 	PRAGMA read_uncommitted =1;
	 	insert into rewards (done) values (4);	
	 	]])
	end
end


function DummyRowDead()
	if tonumber(forms.getthreadNum())==0 then
		emu.writecommand([[
	 	PRAGMA read_uncommitted =1;
	 	insert into rewards (done) values (2);	
	 	]])
	end
end
function DummyRowEnd()
	if tonumber(forms.getthreadNum())==0 then
		emu.writecommand([[
	 	PRAGMA read_uncommitted =1;
	 	insert into rewards (done) values (3);	
	 	]])
	end
end



function EraseLastAction()
	if tonumber(forms.getthreadNum())==0 then
		emu.writecommand([[
			PRAGMA read_uncommitted =1; 
			delete from rewards where score is NULL;
		]])
	end
end


function GatherGenomeNum()
	return emu.getgenome()
end

function GatherSpeciesNum()	
	return emu.getspecies() 
end

function UpdateReward(fitness_value)
	if tonumber(forms.getthreadNum())==0 then
		emu.writecommand([[
		PRAGMA read_uncommitted =1;
		update rewards
		set score=]] .. fitness_value .." ,status= " .. status .." WHERE score is NULL;")
	end
end

function UpdateGenes(GeneCollection)
	print("Update")
	if tonumber(forms.getthreadNum())==0 then
		emu.updategenetable(GeneCollection)
	end
end

function CreateGeneTable()
	if tonumber(forms.getthreadNum())==0 then
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
end