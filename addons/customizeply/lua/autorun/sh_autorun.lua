print("SH AUTORUN LOADED")

if(SERVER) then
    AddCSLuaFile()
    AddCSLuaFile("sh_taunts.lua")
    AddCSLuaFile("cl_menu.lua")
    AddCSLuaFile("cl_taunts.lua")
    include("sh_taunts.lua")
    include("sv_taunts.lua")
    --include("sv_titles.lua") We're using sh_lounge_chatbox/lua/chatbox/sv_chatbox.lua

elseif(CLIENT) then
    include("sh_taunts.lua")
    include("cl_menu.lua")
    include("cl_taunts.lua")

end
