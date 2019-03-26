local totalPoints = 0
local pointsTbl = {}

net.Receive("CTDM.clientScore", function()
    local action = net.ReadString()
    local points = net.ReadInt(11)

    local insert = {
        [action] = {
            ["points"] = points,
            ["timeLeft"] = CurTime() + 5,
            ["stringIndex"] = 0,
            ["added"] = false
        }
    }
    table.insert(pointsTbl, insert)
end)

local SCRW, SCRH = ScrW() / 2, ScrH() * 0.8
local offset = 0

hook.Add("HUDPaint", "CTDM.clientScore", function()
    if (#pointsTbl > 0) then
        draw.DrawText(totalPoints, "DermaLarge", SCRW + 5, SCRH, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)

        for i, actionTbl in pairs(pointsTbl) do
            for actionName, innerVal in pairs(actionTbl) do
                if (innerVal["timeLeft"] < CurTime()) then
                    if (innerVal["stringIndex"] > 0) then
                        innerVal["stringIndex"] = innerVal["stringIndex"] - 1
                    else
                        table.remove(pointsTbl, i)
                    end
                else
                    if (innerVal["stringIndex"] < #actionName) then
                        innerVal["stringIndex"] = innerVal["stringIndex"] + 1
                    end
                    
                    if (not innerVal["added"]) then
                        innerVal["added"] = true
                        totalPoints = totalPoints + innerVal["points"]
                    end
                end

                draw.DrawText(string.sub(actionName, 1, innerVal["stringIndex"]), "DermaLarge", SCRW - 5, SCRH + (25 * offset), Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT)

                offset = offset + 1
            end
        end

        offset = 0
    else
        totalPoints = 0
    end
end)