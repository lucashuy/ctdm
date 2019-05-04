CTDM = CTDM or {}

-- called once when the player connects for the first time
function GM:PlayerInitialSpawn(ply)
    -- makes a call to a database function
    ply:DBNewPlayerSetup()

    -- get player exp to compare against CTDM.levels table so assign player networked data
    local plyEXP = ply:DBGetEXP()
    local totalEXP = 0
    for k, v in pairs(CTDM.levels["levels"]) do
        totalEXP = totalEXP + v["requiredExp"]

        if (plyEXP < totalEXP) then
            ply:SetNWInt("CTDM.rank", k)
            ply:SetNWInt("CTDM.exp", plyEXP)
            ply:SetNWInt("CTDM.expLeft", totalEXP - plyEXP)

            break
        end
    end

    local roundState = GetGlobalInt("CTDM.roundState", CTDM.ROUND_STATE_WAITING)

    -- they are a spectator if they are the first person in the match
    if not roundState == CTDM.ROUND_STATE_ALIVE then
        ply:SetTeam(CTDM.TEAM_SPEC)

        -- if someone joins, setup the round for them
        -- this is here because i dont want rounds to run on an empty server
        if #player.GetAll() > 0 then
            self:SetupRound()
        end
    elseif roundState == CTDM.ROUND_STATE_ALIVE then
        -- TODO: autobalance teams/choose team here
        ply:SetTeam(CTDM.TEAM_BLUE)
    end
end

function GM:PlayerSpawn(ply)
    -- if the spawned and they are not a spectator, apply model/weapons
    if IsValid(ply) and not ply:IsSpectator() then
        self:PlayerSetModel(ply)
        self:PlayerLoadout(ply)

        -- wait for the client to sync with the server before asking them for their saved presets
        timer.Create(ply:Name() .. ".waitToRequestPresets", 0.1, 1, function()
            net.Start("CTDM.requestPresets")
            net.Send(ply)
        end)

        -- TODO: random spawn here

        -- TODO: spawn protection (just god them) here
    elseif IsValid(ply) and ply:IsSpectator() then
        
    end
end

function GM:PlayerSetModel(ply)
    ply:SetModel("models/player/odessa.mdl")
    ply:SetupHands(ply)
end

function GM:PlayerLoadout(ply)
    ply:Give("cw_ak74")
    ply:Give("cw_mr96")
    ply:Give("weapon_fists")
end

function GM:GetFallDamage(ply, speed)
    -- this is CS:S fall damage i think
	return math.max(0, math.ceil(0.2418 * speed - 141.75))
end

function GM:PlayerShouldTakeDamage(ply, att)
    -- TODO: fix me please
    -- something is wrong i think
    if (IsValid(ply) and IsValid(att) and ply:Team() ~= att:Team()) then
        return true
    end

    return false
end

-- hitmarker code
hook.Add("PlayerHurt", "CTDM.hitmarker", function(ply, att)
    if IsValid(ply) and IsValid(att) and ply:Team() ~= att:Team() then
        net.Start("CTDM.hitmarker")
        net.Send(att)
    end
end)

-- return function for the saved weapon presets
net.Receive("CTDM.sendPresets", function(length, ply)
    -- most of this code is from the authors of CW2.0
    -- it appears that their preset retrieval code is called internally, so i just copied it here

    local weapon = net.ReadString()
    local data = net.ReadString()
    data = util.JSONToTable(data)

    if (not ply:HasWeapon(weapon)) then
        return
    end

    weapon = ply:GetWeapon(weapon)

    if (not weapon.CW20Weapon) then
        return
    end

    -- not my code
    local loadOrder = {}
			
	for k, v in pairs(data) do
		local attCategory = weapon.Attachments[k]
		
		if attCategory then
			local att = CustomizableWeaponry.registeredAttachmentsSKey[attCategory.atts[v]]
			
			if att then
				local pos = 1
				
				if att.dependencies or attCategory.dependencies or (weapon.AttachmentDependencies and weapon.AttachmentDependencies[att.name]) then
					pos = #loadOrder + 1
				end
				
				table.insert(loadOrder, pos, {category = k, position = v})
			end
		end
	end

	weapon:detachAll()
	
	for k, v in pairs(loadOrder) do
		weapon:attach(v.category, v.position - 1)
	end
	
	CustomizableWeaponry.grenadeTypes.setTo(weapon, (data.grenadeType or 0), true)
	
	weapon.LastPreset = name_sv

    weapon:SetClip1(weapon:GetMaxClip1())
end)
