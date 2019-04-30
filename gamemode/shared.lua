CTDM = CTDM or {}

GM.Name = "devtest"
GM.Author = "Lucas"
GM.Email = "contact@itslucas.win"
GM.Website = "https://itslucas.win"
GM.TeamBased = true

CTDM.TEAM_BLUE = 0
CTDM.TEAM_RED = 1
CTDM.TEAM_SPEC = 2

function GM:CreateTeams()
    team.SetUp(CTDM.TEAM_BLUE, "Blue", Color(0, 0, 255), true)
    team.SetUp(CTDM.TEAM_RED, "Red", Color(255, 0, 0), true)
    team.SetUp(CTDM.TEAM_SPEC, "Spectator", Color(0, 0, 0), true)
end

local plyMeta = FindMetaTable("Player")

function plyMeta:IsSpectator()
    return self:Team() == CTDM.TEAM_SPEC
end

function plyMeta:GetScore()
    return self:GetNWInt("CTDM.score", 0)
end