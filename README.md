# SpartaHacks17
Castlevania Bizhawk Repo


##Watch this video to get started with Virtual Evolution:
https://www.youtube.com/watch?v=qv6UVOQ0F44

##To understand the code:
-Read Commented.Lua

-Open up EmuHawk

-Load Game From File->Open ROM         ->"Super Mario Bros. (Japan, USA).nes"

-Open Lua Console Tools->Lua Console

-Run script in Lua Console with Script->Load Script   ->Lua->NES->"SethAI.lua"

-In the Fitnes Dialog Box hit the Show Map Button


##Important Bits
http://datacrystal.romhacking.net/wiki/Super_Mario_Bros.:RAM_map

| Bit           | Meaning          | 
| ------------- |:-----------------| 
| 075A          |Lives             |
| 0770          |At Menu or in Game|
|07F9-07FB      |Time              | 
|0747,071E      |Freeze Timer      |  
|07A0           |Level Timer       |

##Distruptive Systems

BizHawk Repo:
https://github.com/TASVideos/BizHawk

Frameavance:
https://github.com/TASVideos/BizHawk/blob/master/BizHawk.Emulation.Cores/Consoles/Nintendo/NES/NES.Core.cs

MABE:
https://github.com/wert23239/MHacks216/blob/master/ros_evolve/src/mabe_ros/World/ROSWorld/ROSWorld.cpp

Lua Translator:
http://www.jeremyong.com/blog/2014/01/10/interfacing-lua-with-templates-in-c-plus-plus-11/

##Valley-Crossing (Novelty Search)

Theory:
http://eplex.cs.ucf.edu/noveltysearch/userspage/

Open-Source Code:
https://github.com/jal278/novelty-search-cpp/blob/master/README
