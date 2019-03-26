CTDM = CTDM or {}

local WIDTH, HEIGHT = 1000, 500

local PLAYER = {
    Setup = function(self, ply)
        self.ply = ply
    end,
    Init = function(self)
        self:Dock(TOP)
        self:DockPadding(4, 0, 0, 4)

        self.name = self:Add("DLabel")
        self.name:Dock(LEFT)
        self.name:SetWidth(200)

        self.ping = self:Add("DLabel")
        self.ping:SetContentAlignment(6)
        self.ping:Dock(RIGHT)
        self.ping:SetWidth(50)

        self.deaths = self:Add("DLabel")
        self.deaths:SetContentAlignment(6)
        self.deaths:Dock(RIGHT)
        self.deaths:SetWidth(50)

        self.kills = self:Add("DLabel")
        self.kills:SetContentAlignment(6)
        self.kills:Dock(RIGHT)
        self.kills:SetWidth(50)

        self.score = self:Add("DLabel")
        self.score:SetContentAlignment(6)
        self.score:Dock(RIGHT)
        self.score:SetWidth(50)
    end,
    Paint = function(self, w, h)
        local plyTeam = self.ply:Team()
        
        if plyTeam == CTDM.TEAM_BLUE then
            surface.SetDrawColor(0, 0, 255, 255)
        elseif plyTeam == CTDM.TEAM_RED then
            surface.SetDrawColor(255, 0, 0, 255)
        else
            surface.SetDrawColor(0, 0, 0, 255)
        end

        surface.DrawRect(0, 0, w, h)
    end,
    Think = function(self)
        if not IsValid(self.ply) then
            self:Remove()
            return
        end

        self.score:SetText(self.ply:GetScore())

        self.name:SetText(self.ply:Name())

        self.kills:SetText(self.ply:Frags())
        self.deaths:SetText(self.ply:Deaths())

        self.ping:SetText(self.ply:Ping())
    end
}
PLAYER = vgui.RegisterTable(PLAYER, "DPanel")

local SCOREBOARD = {
    Init = function(self)
        self.bluePanel = self:Add("DPanel")
        self.bluePanel:Dock(LEFT)
        self.bluePanel:SetSize(490, 0)

        self.bluePanel.header = self.bluePanel:Add("DPanel")
        self.bluePanel.header:SetBackgroundColor(Color(0, 0, 200))
        self.bluePanel.header:Dock(TOP)
        self.bluePanel.header:DockPadding(4, 0, 0, 4)

        self.bluePanel.header.name = self.bluePanel.header:Add("DLabel")
        self.bluePanel.header.name:SetText("Name")
        self.bluePanel.header.name:Dock(LEFT)
        self.bluePanel.header.name:SetWidth(200)

        self.bluePanel.header.ping = self.bluePanel.header:Add("DLabel")
        self.bluePanel.header.ping:SetContentAlignment(6)
        self.bluePanel.header.ping:SetText("Ping")
        self.bluePanel.header.ping:Dock(RIGHT)
        self.bluePanel.header.ping:SetWidth(50)

        self.bluePanel.header.deaths = self.bluePanel.header:Add("DLabel")
        self.bluePanel.header.deaths:SetContentAlignment(6)
        self.bluePanel.header.deaths:SetText("Deaths")
        self.bluePanel.header.deaths:Dock(RIGHT)
        self.bluePanel.header.deaths:SetWidth(50)

        self.bluePanel.header.kills = self.bluePanel.header:Add("DLabel")
        self.bluePanel.header.kills:SetContentAlignment(6)
        self.bluePanel.header.kills:SetText("Kills")
        self.bluePanel.header.kills:Dock(RIGHT)
        self.bluePanel.header.kills:SetWidth(50)

        self.bluePanel.header.score = self.bluePanel.header:Add("DLabel")
        self.bluePanel.header.score:SetContentAlignment(6)
        self.bluePanel.header.score:SetText("Score")
        self.bluePanel.header.score:Dock(RIGHT)
        self.bluePanel.header.score:SetWidth(50)

        self.bluePanel.blueList = self.bluePanel:Add("DScrollPanel")
        self.bluePanel.blueList:Dock(FILL)

        self.redPanel = self:Add("DPanel")
        self.redPanel:Dock(RIGHT)
        self.redPanel:SetSize(490, 0)
        
        self.redPanel.header = self.redPanel:Add("DPanel")
        self.redPanel.header:SetBackgroundColor(Color(200, 0, 0))
        self.redPanel.header:Dock(TOP)
        self.redPanel.header:DockPadding(4, 0, 0, 4)

        self.redPanel.header.name = self.redPanel.header:Add("DLabel")
        self.redPanel.header.name:SetText("Name")
        self.redPanel.header.name:Dock(LEFT)
        self.redPanel.header.name:SetWidth(200)

        self.redPanel.header.ping = self.redPanel.header:Add("DLabel")
        self.redPanel.header.ping:SetContentAlignment(6)
        self.redPanel.header.ping:SetText("Ping")
        self.redPanel.header.ping:Dock(RIGHT)
        self.redPanel.header.ping:SetWidth(50)

        self.redPanel.header.deaths = self.redPanel.header:Add("DLabel")
        self.redPanel.header.deaths:SetContentAlignment(6)
        self.redPanel.header.deaths:SetText("Deaths")
        self.redPanel.header.deaths:Dock(RIGHT)
        self.redPanel.header.deaths:SetWidth(50)

        self.redPanel.header.kills = self.redPanel.header:Add("DLabel")
        self.redPanel.header.kills:SetContentAlignment(6)
        self.redPanel.header.kills:SetText("Kills")
        self.redPanel.header.kills:Dock(RIGHT)
        self.redPanel.header.kills:SetWidth(50)

        self.redPanel.header.score = self.redPanel.header:Add("DLabel")
        self.redPanel.header.score:SetContentAlignment(6)
        self.redPanel.header.score:SetText("Score")
        self.redPanel.header.score:Dock(RIGHT)
        self.redPanel.header.score:SetWidth(50)

        self.redPanel.redList = self.redPanel:Add("DScrollPanel")
        self.redPanel.redList:Dock(FILL)
    end,
    PerformLayout = function(self)
        self:SetSize(WIDTH, HEIGHT)
        self:SetPos(ScrW() / 2 - WIDTH / 2, ScrH() / 2 - HEIGHT / 2)
        self:ShowCloseButton(false)
        self:MakePopup()
        self:SetTitle("")
    end,
    Think = function(self)
        for _, ply in pairs(player.GetAll()) do
            if not IsValid(ply.scoreboardEntry) then
                ply.oldTeam = ply:Team()

                ply.scoreboardEntry = vgui.CreateFromTable(PLAYER)
                ply.scoreboardEntry:Setup(ply)

                if ply:Team() == CTDM.TEAM_BLUE then
                    self.bluePanel.blueList:AddItem(ply.scoreboardEntry)
                elseif ply:Team() == CTDM.TEAM_RED then
                    self.redPanel.redList:AddItem(ply.scoreboardEntry)
                end
            else
                if ply.oldTeam ~= ply:Team() then
                    ply.scoreboardEntry:Remove()
                end
            end
        end
    end
}
SCOREBOARD = vgui.RegisterTable(SCOREBOARD, "DFrame")

local scoreboard

function GM:ScoreboardShow()
    if not IsValid(scoreboard) then
        scoreboard = vgui.CreateFromTable(SCOREBOARD)
    else
        scoreboard:Show()
    end
end

function GM:ScoreboardHide()
    if IsValid(scoreboard) then
        scoreboard:Hide()
    end
end