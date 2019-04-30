CTDM = CTDM or {}

-- load level data into our level global table
local function loadLevelData()
    local file = file.Read("levels.json", "LUA")

    if (file ~= nil) then
        CTDM.levels = util.JSONToTable(file)
    else
        -- TODO: error on invalid level data
    end
end
loadLevelData()