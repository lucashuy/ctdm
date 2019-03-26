CTDM = CTDM or {}
local POINTS_KILL = 100

local plyMeta = FindMetaTable("Player")

function plyMeta:ScoreAdd(score)
    self:SetNWInt("CTDM.score", self:GetNWInt("CTDM.score", 0) + score)
    self:DBAddEXP(score)
end

function plyMeta:ScoreSet(score)
    self:SetNWInt("CTDM.score", score)
end

function plyMeta:ScoreSendToClient(action, points)
    net.Start("CTDM.clientScore")
        net.WriteString(action)
        net.WriteInt(points, 11)
    net.Send(self)
end

function GM:PlayerDeath(ply, wep, att)
    if (IsValid(ply) and IsValid(att) and ply:IsPlayer() and att:IsPlayer() and ply:Team() ~= att:Team()) then
        att:ScoreAdd(POINTS_KILL)
        att:ScoreSendToClient("CTDM.kill", POINTS_KILL)
    end
end