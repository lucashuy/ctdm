CTDM = CTDM or {}

-- probably should change this to a table
local POINTS_KILL = 100

local plyMeta = FindMetaTable("Player")

-- change player score
-- makes a call to a database function
function plyMeta:ScoreAdd(score)
    self:SetNWInt("CTDM.score", self:GetNWInt("CTDM.score", 0) + score)
    self:DBAddEXP(score)
end

-- sets player score (not the same as ScoreAdd())
function plyMeta:ScoreSet(score)
    self:SetNWInt("CTDM.score", score)
end

-- networking to get that point summary thing to show on the client
function plyMeta:ScoreSendToClient(action, points)
    net.Start("CTDM.clientScore")
        net.WriteString(action)
        net.WriteInt(points, 11)
    net.Send(self)
end

-- event handler for player death, give the attacker the points they deserve
function GM:PlayerDeath(ply, wep, att)
    if (IsValid(ply) and IsValid(att) and ply:IsPlayer() and att:IsPlayer() and ply:Team() ~= att:Team()) then
        att:ScoreAdd(POINTS_KILL)
        att:ScoreSendToClient("CTDM.kill", POINTS_KILL)
    end
end