MG_isOneTeam = false

hook.Add("PlayerInitialSpawn", "TS_Select", function(ply)
	AutoChooseTeam(ply)
end)

function Minigames:PlayedStoppedSpectating(ply)
	AutoChooseTeam(ply)
end

function Minigames:PlayerJoinedPreRound(ply)
	ply:Spawn()
end

function Minigames:CanStartGame()
	if #team.GetPlayers(TEAM_BLUE) >= 1 and #team.GetPlayers(TEAM_RED) >= 1 then
		return true
	end

	return false
end

function CheckMapForWeps(ply)
	if table.HasValue(Minigames.MapWithWeapons, game.GetMap()) then
		Minigames:GiveRandom(ply)
	elseif table.HasValue(Minigames.MapWithKnifesOnly, game.GetMap()) then
		ply:Give("weapon_knife")
	else
		return
	end
end

hook.Add("PlayerSpawn", "TS_Colour", function(ply)
	if ply:Team() == TEAM_RED then
		ply:SetPlayerColor(Vector(1,0,0))

		local tbl = table.Random(ents.FindByClass("info_player_terrorist"))

		if tbl then
			ply:SetPos(tbl:GetPos())
		end
		CheckMapForWeps(ply)

	elseif ply:Team() == TEAM_BLUE then
		ply:SetPlayerColor(Vector(0,0,1))
		local tbl = table.Random(ents.FindByClass("info_player_counterterrorist"))

		if tbl then
			ply:SetPos(tbl:GetPos())
		end
		CheckMapForWeps(ply)
	end

	ply:SetWalkSpeed(Minigames.TeamSurvival.WalkSpeed)
	ply:SetRunSpeed(Minigames.TeamSurvival.RunSpeed)
end)


hook.Add("PlayerShouldTakeDamage", "TDM_TS", function(ply,attacker)
	if (attacker:IsPlayer() and ply:IsPlayer() and attacker:Team() == ply:Team()) and attacker != ply then
		return false
	end
end)


hook.Add("RoundBegin", "TS_Timer", function()
	timer.Create("CheckTSWin", 0.5, 0, function()
		Minigames:CheckWinningTeam()
	end)
end)

hook.Add("RoundEnd", "TS_KT", function()
	timer.Destroy("CheckTSWin")
end)
