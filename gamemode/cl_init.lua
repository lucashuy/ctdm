for _, f in pairs(file.Find(GM.FolderName .. "/gamemode/client/*.lua", "LUA")) do
    include("client/" .. f)
end

include("shared.lua")
include("map/gm_construct.lua")

net.Receive("CTDM.requestPresets", function()
    if (IsValid(LocalPlayer())) then
        for k, v in pairs(LocalPlayer():GetWeapons()) do
            if (v.CW20Weapon) then
                -- not my code
                local weaponName = v:GetClass()
                local data = file.Read("cw2_0/presets/" .. weaponName .. "/spawn.txt", "DATA")

                if (data) then
                    net.Start("CTDM.sendPresets")
                    net.WriteString(weaponName)
                    net.WriteString(data)
                    net.SendToServer()
                end
            end
        end
    end
end)