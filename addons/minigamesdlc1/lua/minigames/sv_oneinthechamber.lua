MG_isOneTeam = false

-- We are gonna use TDM as a skeleton here

hook.Add("InitPostEntity", "OITC_Overrides", function()
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

hook.Add("RoundEnd", "OITC_END", function()
	timer.Destroy("CheckEnd")
end)

function Minigames:PlayerJoinedPreRound(ply)
	if ply:Team() != TEAM_SPECTATOR then ply:Spawn() end
end

hook.Add("RoundBegin", "TDM_Check", function()
	timer.Create("CheckEnd", 1, 0, function()
		Minigames:CheckWinningTeam()
	end)
end)


hook.Add("PlayerInitialSpawn", "OITC_Select", function(ply)
	AutoChooseTeam(ply)
end)

hook.Add("PlayerSpawn", "OITC_Color", function(ply)
	if ply:Team() == TEAM_RED then
		ply:SetPlayerColor(Vector(1,0,0))
		local tbl = table.Random(ents.FindByClass("info_player_terrorist"))
		if tbl then
			ply:SetPos(tbl:GetPos())
		end
	elseif ply:Team() == TEAM_BLUE then
		ply:SetPlayerColor(Vector(0,0,1))
		local tbl = table.Random(ents.FindByClass("info_player_counterterrorist"))
		if tbl then
			ply:SetPos(tbl:GetPos())
		end
	end

	ply:SetWalkSpeed(Minigames.OneInTheChamber.WalkSpeed)
	ply:SetRunSpeed(Minigames.OneInTheChamber.RunSpeed)
	ply:Give("weapon_oitc_pistol")
	ply:Give("weapon_knife")

	ply.NumberOfBullets = 1

	net.Start("MG_OITC_Notify")
		net.WriteBool(false)
	net.Send(ply)
end)

hook.Add("PlayerDeath", "OITC_Bullets", function(ply, inflic, attacker)
	if attacker:IsPlayer() then
		attacker.NumberOfBullets = attacker.NumberOfBullets + 1

		net.Start("MG_OITC_Notify")
			net.WriteBool(true)
		net.Send(attacker)
	end
end)

hook.Add("PlayerShouldTakeDamage", "OITC_CHECK", function(ply,attacker)
	if (attacker:IsPlayer() and ply:IsPlayer() and attacker:Team() == ply:Team()) and attacker != ply then
		return false
	end

	return true
end)

hook.Add("RoundEnd", "OITC_Strip", function()
	for k, v in pairs(player.GetAll()) do
		v:StripWeapons()
	end
end)

-- look i'm shit at normal sweps, I have no idea how to make a fuckin melee one so let's cheat
hook.Add("EntityTakeDamage", "FT_Freee", function(ply,dmginfo)
	if not ply:IsPlayer() then return end
	if !dmginfo:GetAttacker() then return end
	if dmginfo:GetAttacker():Team() == ply:Team() then return end

	if dmginfo:GetAttacker():IsPlayer() and dmginfo:GetAttacker():GetActiveWeapon():GetClass() == "weapon_knife" then
		dmginfo:ScaleDamage(100)
		dmginfo:GetAttacker().NumberOfBullets = attacker.NumberOfBullets + 1
		print("MORE BULLET")
		net.Start("MG_OITC_Notify")
			net.WriteBool(true)
		net.Send(ply)
	end
end)
