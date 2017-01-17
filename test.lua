function newPool()
	pool={}
	pool.List={}
end
newPool()
pool.List={}
if(pool.List["Hey"]==nil) then
	pool.List["Hey"]={}
end
pool.List["Hey"]["Hello"]=true
for k,v in pairs(pool.List) do print(k,v) end