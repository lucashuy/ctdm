CTDM = CTDM or {}
CTDM.map = CTDM.map or {}

local CAP_POINTS = 10

local update = 0
hook.Add("Think", "CTDM.playerInZone", function()
    -- checking every 0.25 seconds (instead of every tick)
    if update < CurTime() then
        update = CurTime() + 0.25

        -- for each zone
        for id, zone in pairs(CTDM.map["zones"]) do
            if not zone.update then
                zone.update = 0
            end

            -- do logic for zone points every second
            if zone.update < CurTime() then
                zone.update = CurTime() + 1

                local plysInZone = ents.FindInBox(zone[0], zone[1] + Vector(0, 0, 50))
                local listPlayers = {}

                local contestTeam = CTDM.TEAM_SPEC

                for _, ply in pairs(plysInZone) do
                    if IsValid(ply) and ply:IsPlayer() then
                        if ply:Alive() and not ply:IsSpectator() then
                            if contestTeam == CTDM.TEAM_SPEC then
                                contestTeam = ply:Team()
                            end

                            -- if this player is part of the contesting team, add them to the head count
                            -- otherwise we have someone else in the cap and need to stop it
                            if ply:Team() == contestTeam then
                                table.insert(listPlayers, ply)
                            else
                                listPlayers = {}
                                break
                            end
                        end
                    end
                end

                if #listPlayers > 0 then
                    local pointsAdd = #listPlayers * CAP_POINTS

                    local zoneTeam = GetGlobalInt("CTDM.zoneTeam_" .. id, CTDM.TEAM_SPEC)
                    local zonePoints = GetGlobalInt("CTDM.zonePoints_" .. id, 0)
                    local zoneTeamLast = GetGlobalInt("CTDM.zoneTeamLast_" .. id, CTDM.TEAM_SPEC)

                    -- no one held this zone before
                    if zoneTeamLast == CTDM.TEAM_SPEC then
                        SetGlobalInt("CTDM.zoneTeamLast_" .. id, contestTeam)
                    end

                    -- if decapping
                    if zoneTeamLast ~= contestTeam and zoneTeamLast ~= CTDM.TEAM_SPEC then
                        pointsAdd = pointsAdd * -1
                    end

                    -- if capped to 100%, else if decapped to 0%
                    if zoneTeam ~= contestTeam and zonePoints + pointsAdd >= 100 then
                        print("capped zone")
                        SetGlobalInt("CTDM.zonePoints_" .. id, 100)
                        SetGlobalInt("CTDM.zoneTeam_" .. id, contestTeam)
                        SetGlobalInt("CTDM.zoneTeamLast_" .. id, contestTeam)

                        for _, ply in pairs(listPlayers) do
                            ply:ScoreAdd(500)
                            ply:ScoreSendToClient("CTDM.cap", 500)
                        end

                        continue
                    elseif zoneTeam ~= contestTeam and zonePoints + pointsAdd <= 0 then
                        print("decapped zone")
                        SetGlobalInt("CTDM.zonePoints_" .. id, 0)
                        SetGlobalInt("CTDM.zoneTeam_" .. id, CTDM.TEAM_SPEC)
                        SetGlobalInt("CTDM.zoneTeamLast_" .. id, CTDM.TEAM_SPEC)

                        continue
                    end

                    if contestTeam ~= zoneTeam or zonePoints ~= 100 then
                        print("add points")
                        SetGlobalInt("CTDM.zoneTeam_" .. id, CTDM.TEAM_SPEC)
                        SetGlobalInt("CTDM.zonePoints_" .. id, zonePoints + pointsAdd)
                    end
                end
            end
        end
    end
end)