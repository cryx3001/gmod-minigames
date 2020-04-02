MG_isOneTeam = false

-- We are gonna use TDM as a skeleton here

hook.Add("InitPostEntity", "GG_Overrides", function()
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

hook.Add("RoundEnd", "GG_CheckEND", function()
	timer.Destroy("CheckEnd")

	for k, v in pairs(player.GetAll()) do
		v:StripWeapons()
		v.WeaponLvl = 1
	end
end)

function Minigames:PlayerJoinedPreRound(ply)
	ply:Spawn()
end

hook.Add("RoundBegin", "GG_CheckStart", function()

	for k, v in pairs(player.GetAll()) do
		v:StripWeapons()
		v.WeaponLvl = 1

		v:Give(Minigames.GG.Weapons[v.WeaponLvl])
		v:Give("weapon_knife")
	end
end)


hook.Add("PlayerInitialSpawn", "GG_Pis", function(ply)
	AutoChooseTeam(ply)

	ply.WeaponLvl = 1
end)

hook.Add("PlayerSpawn", "GG_Spawn", function(ply)
	if ply:Team() == TEAM_RED then
		ply:SetPlayerColor(Vector(1,0,0))
		local tbl = table.Random(ents.FindByClass("info_player_terrorist"))
		if tbl then
			ply:SetPos(tbl:GetPos())
		end
		ply:Give(Minigames.GG.Weapons[ply.WeaponLvl])
		ply:Give("weapon_knife")
	elseif ply:Team() == TEAM_BLUE then
		ply:SetPlayerColor(Vector(0,0,1))
		local tbl = table.Random(ents.FindByClass("info_player_counterterrorist"))
		if tbl then
			ply:SetPos(tbl:GetPos())
		end

		ply:Give(Minigames.GG.Weapons[ply.WeaponLvl or 1])
		ply:Give("weapon_knife")
	end

	ply:SetWalkSpeed(Minigames.GG.WalkSpeed)
	ply:SetRunSpeed(Minigames.GG.RunSpeed)

	if Minigames.GG.SpawnProtection > 0 then
		ply:SetRenderMode(1)
		ply:GodEnable()
		ply:SetColor(Color(255,255,255,180))

		timer.Simple(Minigames.GG.SpawnProtection, function()
			ply:GodDisable()
			ply:SetColor(Color(255,255,255,255))
			ply:SetRenderMode(0)
		end)
	end
end)

hook.Add("PlayerDeath", "GG_Death", function(ply,inflic,attacker)
	if attacker:IsPlayer() and attacker != ply then
		local activeWeapon = attacker:GetActiveWeapon():GetPrintName() //Ca marche donc fuck off

		attacker:StripWeapons()
		attacker.WeaponLvl = attacker.WeaponLvl + 1

		if activeWeapon == "Knife" then
			ply.WeaponLvl = ply.WeaponLvl - 1
			if ply.WeaponLvl < 1 then ply.WeaponLvl = 1 end
		end

		if Minigames.GG.Weapons[attacker.WeaponLvl] != nil  then
			if Minigames.GG.Weapons[attacker.WeaponLvl] == "weapon_knife" then
				attacker:Give(Minigames.GG.Weapons[attacker.WeaponLvl])
			else
				attacker:Give(Minigames.GG.Weapons[attacker.WeaponLvl])
				attacker:Give("weapon_knife")
			end
			attacker:SelectWeapon(Minigames.GG.Weapons[attacker.WeaponLvl])
		end

		if attacker.WeaponLvl > #Minigames.GG.Weapons then
			net.Start("MG_NotifyGG")
			net.Send(attacker)

			Minigames:RoundEnd(attacker:Team())
		end

	elseif attacker:IsPlayer() and attacker == ply then
		attacker:StripWeapons()
		attacker.WeaponLvl = attacker.WeaponLvl - 1
		if attacker.WeaponLvl < 1 then attacker.WeaponLvl = 1 end
	end


	timer.Simple(Minigames.GG.RespawnTime, function()
		if ply:Team() != TEAM_SPECTATOR then
			ply:Spawn()
		end
	end)

end)

hook.Add("PlayerShouldTakeDamage", "GG_Damage", function(ply,attacker)
	if (attacker:IsPlayer() and ply:IsPlayer() and attacker:Team() == ply:Team()) and attacker != ply then
		return false
	end

	return true
end)
