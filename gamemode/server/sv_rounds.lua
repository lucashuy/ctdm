CTDM = CTDM or {}
CTDM.map = CTDM.map or {}

CTDM.ROUND_STATE_WAITING = 0
CTDM.ROUND_STATE_SETUP = 1
CTDM.ROUND_STATE_ALIVE = 2
CTDM.ROUND_STATE_END = 3

local STARTING_POINTS = 500 -- these could be variable depending on the map
local SCORE_TICK_ZONE = 3

-- main round ticking logic
-- executes every 5 seconds
local time = 0
hook.Add("Tick", "CTDM.roundManager", function()
    if time < CurTime() then
        time = CurTime() + 5

        -- get both team's points
        local bluePoints, redPoints = GetGlobalInt("CTDM.bluePoints", STARTING_POINTS), GetGlobalInt("CTDM.redPoints", STARTING_POINTS)


        if (bluePoints <= 0 or redPoints <= 0) and GetGlobalInt("CTDM.roundState", ROUND_STATE_WAITING) == CTDM.ROUND_STATE_ALIVE then
            -- if the points on either team is 0 AND if the round is currently active
            GAMEMODE:EndRound(false)
        else
            -- else, then the round is still in play

            local numBlueZones, numRedZones = 0, 0

            -- begin counting the number of zones that each team holds
            for id, zone in pairs(CTDM.map["zones"]) do
                local zoneTeam = GetGlobalInt("CTDM.zoneTeam_" .. id, CTDM.TEAM_SPEC)

                if zoneTeam == CTDM.TEAM_BLUE then
                    numBlueZones = numBlueZones + 1
                elseif zoneTeam == CTDM.TEAM_RED then
                    numRedZones = numRedZones + 1
                end
            end
            
            -- calculate the number of points to count down from each team
            local bluePointRemove = numBlueZones * SCORE_TICK_ZONE
            local redPointRemove = numRedZones * SCORE_TICK_ZONE

            -- if any of the points underflow, set them to zero and end the game
            -- otherwise, update the networked values
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

-- this gets called once when the gamemode loads
function GM:Initialize()
    --[[
    local build = file.Read("gamemodes/ctdm/BUILD", "GAME")

    SetGlobalInt("CTDM.roundState", CTDM.ROUND_STATE_WAITING)
    SetGlobalString("CTDM.version", "[CTDM][0.1." .. build .. "]")
    ]]
end

function GM:SetupRound()
    -- set the round state and cleanup the map of any ragdolls or blood etc
    SetGlobalInt("CTDM.roundState", CTDM.ROUND_STATE_SETUP)
    game.CleanUpMap()

    -- respawn everyone and freeze them (no camera or movement)
    for _, ply in pairs(player.GetAll()) do
        ply:KillSilent()
        ply:Spawn()

        ply:SetMoveType(MOVETYPE_NONE)
    end

    -- remember to unfreeze them
    timer.Create("CTDM.unfreezePlayers", 5, 1, function()
        SetGlobalInt("CTDM.roundState", CTDM.ROUND_STATE_ALIVE)

        for _, ply in pairs(player.GetAll()) do
            ply:SetMoveType(MOVETYPE_WALK)
        end
    end)
end

function GM:EndRound(forced)
    -- round has ended
    SetGlobalInt("CTDM.roundState", CTDM.ROUND_STATE_END)

    SetGlobalInt("CTDM.redPoints", STARTING_POINTS)
    SetGlobalInt("CTDM.bluePoints", STARTING_POINTS)

    -- reset all the zones
    for id, zone in pairs(CTDM.map["zones"]) do
        SetGlobalInt("CTDM.zonePoints_" .. id, 0)
        SetGlobalInt("CTDM.zoneTeam_" .. id, CTDM.TEAM_SPEC)
        SetGlobalInt("CTDM.zoneTeamLast_" .. id, CTDM.TEAM_SPEC)
    end

    -- reset player stats
    for _, ply in pairs(player.GetAll()) do
        ply:ScoreSet(0)
        ply:SetFrags(0)
        ply:SetDeaths(0)
    end

    self:SetupRound()
end