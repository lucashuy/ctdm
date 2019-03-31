local WIDTH, HEIGHT = 500, 500

local MENU = {
    Init = function(self)

    end
}
MENU = vgui.RegisterTable(MENU, "DFrame")

local gunMenu

net.Receive("CTDM.openGunMenu", function()
    if (not IsValid(gunMenu)) then
        gunMenu = vgui.CreateFromTable(MENU)
    end

    gunMenu:SetVisible(not gunMenu:IsVisible())
end)