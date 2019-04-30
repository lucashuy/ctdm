util.AddNetworkString("CTDM.hitmarker")
util.AddNetworkString("CTDM.clientScore")
util.AddNetworkString("CTDM.requestPresets")
util.AddNetworkString("CTDM.sendPresets")
util.AddNetworkString("CTDM.openGunMenu")

for _, f in pairs(file.Find(GM.FolderName .. "/gamemode/server/*.lua", "LUA")) do
    include("server/" .. f)
end

include("shared.lua")

for _, f in pairs(file.Find(GM.FolderName .. "/gamemode/map/*.lua", "LUA")) do
	if f == game.GetMap() .. ".lua" then
		include("map/" .. f)
        AddCSLuaFile("map/" .. f)

		break
	end
end

for _, f in pairs(file.Find(GM.FolderName .. "/gamemode/client/*.lua", "LUA")) do
    AddCSLuaFile("client/" .. f)
end

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

hook.Add("PlayerHurt", "CTDM.hitmarker", function(ply, att)
    if IsValid(ply) and IsValid(att) and ply:Team() ~= att:Team() then
        net.Start("CTDM.hitmarker")
        net.Send(att)
    end
end)