CTDM = CTDM or {}
CTDM.map = CTDM.map or {}

CTDM.ROUND_STATE_WAITING = 0
CTDM.ROUND_STATE_SETUP = 1
CTDM.ROUND_STATE_ALIVE = 2
CTDM.ROUND_STATE_END = 3

local STARTING_POINTS = 500
local SCORE_TICK_ZONE = 3

local time = 0
hook.Add("Tick", "CTDM.roundManager", function()
    if time < CurTime() then
        time = CurTime() + 5

        local bluePoints, redPoints = GetGlobalInt("CTDM.bluePoints", STARTING_POINTS), GetGlobalInt("CTDM.redPoints", STARTING_POINTS)

        if (bluePoints <= 0 or redPoints <= 0) and GetGlobalInt("CTDM.roundState", ROUND_STATE_WAITING) == CTDM.ROUND_STATE_ALIVE then
            GAMEMODE:EndRound(false)
        else
            local numBlueZones, numRedZones = 0, 0

            for id, zone in pairs(CTDM.map["zones"]) do
                local zoneTeam = GetGlobalInt("CTDM.zoneTeam_" .. id, CTDM.TEAM_SPEC)

                if zoneTeam == CTDM.TEAM_BLUE then
                    numBlueZones = numBlueZones + 1
                elseif zoneTeam == CTDM.TEAM_RED then
                    numRedZones = numRedZones + 1
                end
            end
            
            local bluePointRemove = numBlueZones * SCORE_TICK_ZONE
            local redPointRemove = numRedZones * SCORE_TICK_ZONE

            if bluePoints - bluePointRemove <= 0 then
                SetGlobalInt("CTDM.bluePoints", 0)
                GAMEMODE:EndRound(false)
            elseif redPoints - redPointRemove <= 0 then
                SetGlobalInt("CTDM.redPoints", 0)
                GAMEMODE:EndRound(false)
            else
                SetGlobalInt("CTDM.bluePoints", bluePoints - bluePointRemove)
                SetGlobalInt("CTDM.redPoints", redPoints - redPointRemove)
            end
        end
    end
end)

function GM:Initialize()
    SetGlobalInt("CTDM.roundState", CTDM.ROUND_STATE_WAITING)
    SetGlobalString("CTDM.version", "[CTDM][0.0.1]")
end

function GM:SetupRound()
    SetGlobalInt("CTDM.roundState", CTDM.ROUND_STATE_SETUP)
    game.CleanUpMap()

    for _, ply in pairs(player.GetAll()) do
        ply:KillSilent()
        ply:Spawn()

        ply:SetMoveType(MOVETYPE_NONE)
    end

    timer.Create("CTDM.unfreezePlayers", 5, 1, function()
        SetGlobalInt("CTDM.roundState", CTDM.ROUND_STATE_ALIVE)

        for _, ply in pairs(player.GetAll()) do
            ply:SetMoveType(MOVETYPE_WALK)
        end
    end)
end

function GM:EndRound(forced)
    SetGlobalInt("CTDM.roundState", CTDM.ROUND_STATE_END)

    SetGlobalInt("CTDM.redPoints", STARTING_POINTS)
    SetGlobalInt("CTDM.bluePoints", STARTING_POINTS)

    for id, zone in pairs(CTDM.map["zones"]) do
        SetGlobalInt("CTDM.zonePoints_" .. id, 0)
        SetGlobalInt("CTDM.zoneTeam_" .. id, CTDM.TEAM_SPEC)
        SetGlobalInt("CTDM.zoneTeamLast_" .. id, CTDM.TEAM_SPEC)
    end

    for _, ply in pairs(player.GetAll()) do
        ply:ScoreSet(0)
        ply:SetFrags(0)
        ply:SetDeaths(0)
    end

    self:SetupRound()
end