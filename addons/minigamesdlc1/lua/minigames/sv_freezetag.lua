MG_isOneTeam = false

hook.Add("InitPostEntity", "FT_Overrides", function()
	function Minigames:CanStartGame()
		if #team.GetPlayers(TEAM_BLUE) >= 1 and #team.GetPlayers(TEAM_RED) >= 1 then
			return true
		end

		return false
	end

	function Minigames:PlayedStoppedSpectating(ply)
		AutoChooseTeam(ply)
	end

end)

hook.Add("RoundBegin", "FT_CHECK", function()
	timer.Create("CheckEnd", 1, 0, function()
		Minigames.FreezeTag:CheckWin()
	end)
end)

hook.Add("RoundEnd", "FT_Kill", function()
	timer.Destroy("CheckEnd")
end)

function Minigames:PlayerJoinedPreRound(ply)
	ply:Spawn()
end


hook.Add("PlayerInitialSpawn", "FT_Sleect", function(ply)
	AutoChooseTeam(ply)
end)

function Minigames:PlayedStoppedSpectating(ply)
	AutoChooseTeam(ply)
end

function Minigames:CanStartGame()
	if #team.GetPlayers(TEAM_BLUE) >= 1 and #team.GetPlayers(TEAM_RED) >= 1 then
		return true
	end

	return false
end

hook.Add("PlayerSpawn", "Ft_Col", function(ply)
	local spawnRed = table.Random(ents.FindByClass("info_player_terrorist"))
	local spawnBlue = table.Random(ents.FindByClass("info_player_counterterrorist"))

	ply:SetColor(255,255,255,255)

	if ply:Team() == TEAM_RED then
		if spawnRed then
			ply:SetPos(spawnRed:GetPos())
		end
		ply:SetPlayerColor(Vector(1,0,0))

	elseif ply:Team() == TEAM_BLUE then
		ply:SetPlayerColor(Vector(0,0,1))
		if spawnBlue then
			ply:SetPos(spawnBlue:GetPos())
		end
	end

	ply:SetWalkSpeed(275)
	ply:SetRunSpeed(275)

	for k, v in pairs(Minigames.FreezeTag.Weapons) do
		ply:Give(v)
	end
end)

hook.Add("PlayerDeath", "FT_Fallback", function(ply,i,a)
	ply:Freeze(false)
end)

hook.Add("EntityTakeDamage", "FT_Freee", function(ply,dmginfo)
	if not ply:IsPlayer() then return end

	if not ply:IsFrozen() then
		if ply:Team() == dmginfo:GetAttacker():Team() then return end
		if ply:Health()-dmginfo:GetDamage() <= 0 then
			dmginfo:SetDamage(0)
			ply:SetHealth(1)
			ply.OriginalCol = ply:GetColor()
			ply:Freeze(true)
			ply:SetColor(Color(0,0,255))
			dmginfo:GetAttacker():AddFrags(1)

			for k, v in pairs(player.GetAll()) do
				if v:Team() == ply:Team() then
					net.Start("MG_NotifyFrozen")
						net.WriteEntity(ply)
					net.Send(v)
				end
			end
		end
	else
		if ply:Team() == dmginfo:GetAttacker():Team() then
			local num = dmginfo:GetDamage()
			dmginfo:SetDamage(0)

			dmginfo:GetAttacker():AddFrags(1)
			ply:SetHealth(ply:Health()+num)

			if ply:Health() >= 100 then
				ply:Freeze(false)
				ply:SetHealth(100)
				ply:SetColor(ply.OriginalCol)
			end
		end
	end
end)

function Minigames.FreezeTag:GetFrozen(teamid)
	local tbl = {}

	for k, v in pairs(team.GetPlayers(teamid)) do
		if v:IsFrozen() then
			table.insert(tbl,v)
		end
	end

	return tbl
end

function Minigames.FreezeTag:CheckWin()
	if #Minigames.FreezeTag:GetFrozen(TEAM_BLUE) == #Minigames:ReturnBlueAlive() then
		Minigames:RoundEnd(TEAM_BLUE)
	elseif #Minigames.FreezeTag:GetFrozen(TEAM_RED) == #Minigames:ReturnRedAlive() then
		Minigames:RoundEnd(TEAM_RED)
	end
end

hook.Add("PlayerShouldTakeDamage", "FT_Damage", function(ply,attacker)
	if attacker:IsPlayer() and ply:IsPlayer() then
		if attacker:Team() == ply:Team() then
			return false
		else
			if ply:IsFrozen() then
				return false
			else
				return true
			end
		end
	end
end)

hook.Add("RoundEnd", "TDM_Strip", function()
	for k, v in pairs(player.GetAll()) do
		v:StripWeapons()
		v:Freeze(false)
		if v.OriginalCol and v:GetColor() != v.OriginalCol then
			v:SetColor(v.OriginalCol)
		end
	end
end)
