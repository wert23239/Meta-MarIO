
pooltest={}
pooltest.List={}
pooltest.List={}
if(pooltest.List["Hey"]==nil) then
	pooltest.List["Hey"]={}
end

print(pooltest.List["Hey"]["Hello"])

if not pooltest.List["Hey"]["Hello"]==true then
	pooltest.List["Hey"]["Hello"]=true 
end

print(pooltest.List["Hey"]["Hello"])