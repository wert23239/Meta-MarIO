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



function EraseLastAction()
	emu.writecommand([[
		PRAGMA read_uncommitted =1; 
		delete from rewards where score is NULL;
	]])
end


function UpdateReward(fitness_value)
	emu.writecommand([[=1;
	PRAGMA read_uncommitted 
	update rewards
	set score=]] .. fitness_value .." WHERE score is NULL")

end


