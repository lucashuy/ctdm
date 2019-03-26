local hit = false
local alpha = 0
local SCRW, SCRH = ScrW() / 2, ScrH() / 2
local time = 0

net.Receive("CTDM.hitmarker", function()
    time = CurTime() + 0.1
    hit = true
    alpha = 255
end)

hook.Add("HUDPaint", "CTDM.hitmarkerPaint", function()
    if hit then
		surface.SetDrawColor(255, 255, 255, 255)

        -- top 2
        surface.DrawLine(ScrW() / 2 - 7, ScrH() / 2 - 7, ScrW() / 2 - 1, ScrH() / 2 - 1)
        surface.DrawLine(ScrW() / 2 + 7, ScrH() / 2 - 7, ScrW() / 2 + 1, ScrH() / 2 - 1)

        -- bottom 2
        surface.DrawLine(ScrW() / 2 - 7, ScrH() / 2 + 7, ScrW() / 2 - 1, ScrH() / 2 + 1)
        surface.DrawLine(ScrW() / 2 + 7, ScrH() / 2 + 7, ScrW() / 2 + 1, ScrH() / 2 + 1)
	end
end)

hook.Add("Think", "CTDM.hitmarkerLerp", function()
    if hit then
        if time < CurTime() then
            hit = false
        end
    end
end)