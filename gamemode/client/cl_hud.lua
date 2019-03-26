CTDM = CTDM or {}
CTDM.map = CTDM.map or {}

surface.CreateFont("CTDM.HP", {
    font = "Roboto",
    size = 16,
    weight = 500
})

local BAR_LENGTH = 250
local BAR_HEIGHT = 25
local BAR_LERP_SMOOTH = 0.1

local currHP = 0
local STARTING_POINTS = 500

hook.Add("Think", "CTDM.smoothHP", function()
    if currHP ~= LocalPlayer():Health() then
        currHP = Lerp(BAR_LERP_SMOOTH, currHP, LocalPlayer():Health())
        if (currHP >= LocalPlayer():GetMaxHealth() - 0.1) then
            currHP = LocalPlayer():GetMaxHealth();
        end
    end
end)

local function paintZoneMarker()
    for id, zone in pairs(CTDM.map["zones"]) do
        local zoneMarker = (zone["center"] + Vector(0, 0, 125)):ToScreen()

        draw.DrawText(string.char(string.byte("A") + id), "DermaLarge", zoneMarker.x, zoneMarker.y, Color(255, 255, 255), TEXT_ALIGN_CENTER)

        -- I know this is an "expensive call". No I don't care.
        local dist = LocalPlayer():GetPos():Distance(zone["center"])
        draw.DrawText(math.ceil(dist / 53) .. "m", "Trebuchet24", zoneMarker.x, zoneMarker.y + 25, Color(255, 255, 255), TEXT_ALIGN_CENTER)
    end
end

local function paintHealth()
    surface.SetDrawColor(255, 255, 255, 255)
    surface.DrawRect(10, ScrH() - BAR_HEIGHT - 10, BAR_LENGTH, BAR_HEIGHT)

    surface.SetDrawColor(0, 255, 0, 255)
    surface.DrawRect(10, ScrH() - BAR_HEIGHT - 10, (currHP / LocalPlayer():GetMaxHealth()) * BAR_LENGTH, BAR_HEIGHT)

    draw.DrawText(currHP, "CTDM.HP", BAR_LENGTH + 20, ScrH() - BAR_HEIGHT - 10, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
end

local function paintScores()
    surface.SetTextPos(10, 100)
    surface.DrawText(GetGlobalInt("CTDM.redPoints", STARTING_POINTS))

    surface.SetTextPos(10, 140)
    surface.DrawText(GetGlobalInt("CTDM.bluePoints", STARTING_POINTS))
end

function GM:HUDPaint()
    if LocalPlayer():Alive() then
        surface.SetFont("DermaLarge")
	    surface.SetTextColor(255, 255, 255)

	    surface.SetTextPos(10, 10)
        surface.DrawText(GetGlobalString("CTDM.version", ""))

	    surface.SetTextPos(10, 300)
        surface.DrawText("RANK: " .. LocalPlayer():GetNWInt("CTDM.rank", 1))
	    surface.SetTextPos(10, 325)
        surface.DrawText("EXP: " .. LocalPlayer():GetNWInt("CTDM.exp", 0))

        paintScores()

        paintHealth()
        paintZoneMarker()
    end
end

local hideElements = {
    ["CHudAmmo"] = false,
    ["CHudBattery"] = true,
    ["CHudCrosshair"] = true,
    ["CHudHealth"] = true
}

function GM:HUDShouldDraw(element)
    if hideElements[element] then
        return false
    end

    return true
end
