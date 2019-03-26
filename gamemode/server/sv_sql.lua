print("[CTDM] Initializing databases.")

sql.Query("CREATE TABLE IF NOT EXISTS `CTDM.players` (`steamid` INTEGER)");
sql.Query("CREATE TABLE IF NOT EXISTS `CTDM.levels` (`steamid` INTEGER, `rank` INTEGER, `exp` INTEGER)");

print("[CTDM] Completed initialization of databases.")

local plyMeta = FindMetaTable("Player")

function plyMeta:DBNewPlayerSetup()
    local plySteamID = self:SteamID64()
    local plyExists = sql.QueryValue("SELECT `steamid` FROM `CTDM.players` WHERE `steamid` = " .. plySteamID)

    if (plyExists == nil) then
        sql.Query("INSERT INTO `CTDM.players` (`steamid`) VALUES (" .. plySteamID .. ")")
        sql.Query("INSERT INTO `CTDM.levels` (`steamid`, `rank`, `exp`) VALUES (" .. plySteamID .. ", 1, 0)")

        self:SetNWInt("CTDM.rank", 1)
        self:SetNWInt("CTDM.exp", 0)

        return
    end

    local plyLevelInfo = sql.QueryRow("SELECt * FROM `CTDM.levels` WHERE `steamid` = " .. plySteamID)
    self:SetNWInt("CTDM.rank", plyLevelInfo.rank)
    self:SetNWInt("CTDM.exp", plyLevelInfo.exp)
end

function plyMeta:DBAddEXP(exp)
    local expToAdd = self:GetNWInt("CTDM.exp", 0) + exp
    self:SetNWInt("CTDM.exp", expToAdd)
    sql.Query("UPDATE `CTDM.levels` SET `exp` = " .. (expToAdd) .. " WHERE `steamid` = " .. self:SteamID64())

end