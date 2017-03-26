::rem:: --[[
@setlocal&  set PATH=C:/torch/install/.;%PATH% & set luafile="%~f0" & if exist "%~f0.bat" set luafile="%~f0.bat"
@C:/torch/install/./luajit.exe %luafile% %*&  exit /b ]]

package.path = [[C:/torch/install/lua/?.lua;C:/torch/install/lua/?/init.lua;]]..package.path

-- this should be loaded first.
local cfg = require("luarocks.cfg")

local loader = require("luarocks.loader")
local command_line = require("luarocks.command_line")

program_description = "LuaRocks repository administration interface"

commands = {
   help = "luarocks.help",
   make_manifest = "luarocks.make_manifest",
   add = "luarocks.add",
   remove = "luarocks.admin_remove",
   refresh_cache = "luarocks.refresh_cache",
}

command_line.run_command(...)
