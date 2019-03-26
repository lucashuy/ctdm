CTDM = CTDM or {}
CTDM.map = CTDM.map or {}

function GM:PostDrawTranslucentRenderables()
    local playerPos = LocalPlayer():GetPos()

    if playerPos:DistToSqr(CTDM.map["spawnRed"]["center"]) < 2000000 then
        render.DrawWireframeBox(
            Vector(0, 0, 0),
            Angle(0, 0, 0, 0, 0, 0),
            CTDM.map["spawnRed"]["outline"][0],
            CTDM.map["spawnRed"]["outline"][1],
            CTDM.map["spawnRed"]["colour"],
            false
        )
    end

    for id, zone in pairs(CTDM.map["zones"]) do
        local playerPosToZone = playerPos:DistToSqr(zone["center"])

        if playerPosToZone < 1700000 then
            local colour
            local zoneTeam = GetGlobalInt("CTDM.zoneTeam_" .. id, CTDM.TEAM_SPEC)

            if zoneTeam == CTDM.TEAM_BLUE then
                colour = Color(0, 0, 255)
            elseif zoneTeam == CTDM.TEAM_RED then
                colour = Color(255, 0, 0)
            else
                colour = Color(255, 255, 255)
            end

            render.DrawWireframeBox(
                Vector(0, 0, 0),
                Angle(0, 0, 0, 0, 0, 0),
                zone[0],
                zone[1],
                colour,
                false
            )
        end
    end
end

hook.Add("HUDPaint", "CTDM.zoneCapBar", function()
    local playerPos = LocalPlayer():GetPos()

    for id, zone in pairs(CTDM.map["zones"]) do
        -- guess I have to literally make a box
        if playerPos:WithinAABox(zone[0] - Vector(0, 0, 20), zone[1] + Vector(0, 0, 50)) then
            surface.SetDrawColor(255, 255, 255, 255)
            -- x, y, w, h
            surface.DrawRect(ScrW() / 2 - 50, ScrH() - 60 - 10, 100, 50)

            local colour
            local zoneHold = GetGlobalInt("CTDM.zoneTeamLast_" .. id, CTDM.TEAM_SPEC)

            if zoneHold == CTDM.TEAM_BLUE then
                colour = Color(0, 0, 255)
            elseif zoneHold == CTDM.TEAM_RED then
                colour = Color(255, 0, 0)
            else
                colour = Color(0, 0, 0)
            end

            -- TODO: maybe make this linear increase
            surface.SetDrawColor(colour.r, colour.g, colour.b, 255)
            surface.DrawRect(ScrW() / 2 - 50, ScrH() - 60 - 10, GetGlobalInt("CTDM.zonePoints_" .. id, 0), 50)
        end
    end
end)