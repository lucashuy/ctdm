CTDM = CTDM or {}

-- load level data into our level global table
local function loadLevelData()
    -- TODO: move levels.json somewhere else, probably some config/content/data folder
    local file = file.Read("gamemodes/ctdm/gamemode/levels.json", "GAME")

    if (file ~= nil) then
        CTDM.levels = util.JSONToTable(file)
    else
        print("[CTDM] Invalid level data")
    end
end
loadLevelData()