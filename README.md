[![Stories in Ready](https://badge.waffle.io/wert23239/Meta-MarIO.png?label=ready&title=Ready)](https://waffle.io/wert23239/Meta-MarIO)




![ContinousPlay.gif](ContinousPlay.gif?raw=true "Optional Title" | width="150" height="250")
![ContinousDeath.gif](ContinousDeath.gif "Optional Title")
![GraphVisualization.gif](GraphVisualization.gif?raw=true "Optional Title")



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

Basic Comprendium

http://datacrystal.romhacking.net/wiki/Super_Mario_Bros.:RAM_map

More Detailed Comprendium:

https://gist.github.com/1wErt3r/4048722

| Bit           | Meaning          | 
| ------------- |:-----------------| 
| 075A          |Lives             |
| 0770          |At Menu or in Game|
|07F9-07FB      |Time              | 
|0747,071E      |Freeze Timer      |  
|07A0           |Level Timer       |
|07D8-07DD      |Score             |
|000E           |Dead,alive or can't move        |
|00B5           |Determine if player is in a pit|
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


##Tweaked SethBling Version

http://pastebin.com/juRnkyEf

##Bizhawk Form Lua 
https://github.com/denilsonsa/bizhawk-lua-scripts

###GUI Goals
http://socialblade.com/youtube/user/pewdiepie/realtime


