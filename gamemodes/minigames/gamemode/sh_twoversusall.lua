MG_MustJoinBlue = true
MG_isOneTeam = true

local tbl = {}
local picked_1
local picked_2
local pickedLastRound_1
local pickedLastRound_2

hook.Add("PlayerInitialSpawn", "TVA_Spawn", function(ply)
	timer.Simple(1, function()
		ply:SetTeam(TEAM_BLUE)
		checkSpawnForTeam(ply)
		ply:Freeze(true)
	end)
end)

function Minigames:PlayedStoppedSpectating(ply)
	ply:SetTeam(TEAM_BLUE)
end

function Minigames:PlayerJoinedPreRound(ply)
	if (ply:Team() == TEAM_BLUE or ply:Team() == TEAM_RED) then
		ply:Spawn()
	end
end

function Minigames:PlayerConnectedPreround(ply)
	if not ply:IsPlayingGame() then
		ply:SetTeam(TEAM_BLUE)
	end

	if not ply:Alive() and (ply:Team() == TEAM_BLUE or ply:Team() == TEAM_RED)  then
		ply:Spawn()
	end
end

function Minigames:CanStartGame()
	if #team.GetPlayers(TEAM_BLUE) >= 2 or #team.GetPlayers(TEAM_RED) > 0 then
		return true
	end

	return false
end

/*
hook.Add("PlayerSpawn", "GiveCrowbar", function(ply)
	ply:Give("weapon_crowbar")
end)
*/

function pickRedPlayer(arg)
	picked_1 = table.Random(Minigames:ReturnBlueAlive())

	if !table.HasValue(Minigames.OneVersusAll, game.GetMap()) then
		picked_2 = table.Random(Minigames:ReturnBlueAlive())
		while picked_1 == picked_2 do picked_2 = table.Random(Minigames:ReturnBlueAlive()) end
	end
end

function checkSpawnForTeam(ply)
	local spawnRed = table.Random(ents.FindByClass("info_player_terrorist"))
	local spawnBlue = table.Random(ents.FindByClass("info_player_counterterrorist"))
	if ply:Team() == TEAM_RED then
		ply:Spawn()
		ply:SetPos(spawnRed:GetPos())
	else
		ply:Spawn()
		ply:SetPos(spawnBlue:GetPos())
	end
end

hook.Add("PreRoundBegin", "TVA_PRB", function()
	local spawnRed = table.Random(ents.FindByClass("info_player_terrorist"))
	local spawnBlue = table.Random(ents.FindByClass("info_player_counterterrorist"))

	pickRedPlayer()
	while picked_1 == pickedLastRound_1 do picked_1 = table.Random(Minigames:ReturnBlueAlive()) end

	if !table.HasValue(Minigames.OneVersusAll, game.GetMap()) then
		while picked_2 == pickedLastRound_2 do picked_2 = table.Random(Minigames:ReturnBlueAlive()) end
	end

	if not IsValid(picked_1) then
		Minigames.RoundState = -1
		Minigames:CheckForPlayers()
	else
		picked_1:KillSilent()
		picked_1:SetTeam(TEAM_RED)
		picked_1:SetPlayerColor(Vector(1,0,0))
	end

	if !table.HasValue(Minigames.OneVersusAll, game.GetMap()) then
		if not IsValid(picked_2) then
			Minigames.RoundState = -1
			Minigames:CheckForPlayers()
		else
			picked_2:KillSilent()
			picked_2:SetTeam(TEAM_RED)
			picked_2:SetPlayerColor(Vector(1,0,0))
		end
	end

	for k, v in pairs(player.GetAll()) do
		if v:Team() != TEAM_SPECTATOR then
			if v:Team() == TEAM_RED then
				v:Spawn()
				v:SetPos(spawnRed:GetPos())
			else
				v:Spawn()
				v:SetPos(spawnBlue:GetPos())
			end
		end
	end

	for k, v in pairs(player.GetAll()) do
		v:Freeze(true)
	end
end)

hook.Add("PreRoundPlayer", "TVA_Colour", function(ply)
	ply:SetPlayerColor(Vector(0,0,1))
end)

hook.Add("RoundBegin", "TVA_Checkwin", function()
	for k, v in pairs(player.GetAll()) do
		v:Freeze(false)
	end

	local ForCheckTSAEndTimerTime = 1
	local spawnBlue = table.Random(ents.FindByClass("info_player_counterterrorist"))
	if player.GetCount() <= 2 and !table.HasValue(Minigames.OneVersusAll, game.GetMap()) then
		picked_2:KillSilent()
		picked_2:SetTeam(TEAM_BLUE)
		picked_2:Spawn()
		picked_2:SetPos(spawnBlue:GetPos())
		picked_2:SetPlayerColor(Vector(1,0,0))
		ForCheckTSAEndTimerTime = 3
		net.Start("TVA_AutoBalance")
			net.WriteString(tostring(picked_2:Name()))
		net.Broadcast()

	end


	timer.Create("CheckTSAEnd", ForCheckTSAEndTimerTime, 0, function()
		Minigames:CheckWinningTeam()
	end)


	local spawnRed = ents.FindByClass("info_player_terrorist")
	local spawnBlue = ents.FindByClass("info_player_counterterrorist")

	local numRed = 1
	local numBlue = 1
	for k, v in pairs(player.GetAll()) do
		if v:Team() != TEAM_SPECTATOR then
			if v:Team() == TEAM_RED then
				v:Spawn()
				v:SetPos(spawnRed[numRed]:GetPos())

				if spawnRed[numRed+1] == nil then
					numRed = 1
				elseif  spawnRed[numRed+1]:GetPos() == nil then
					numRed = 1
				else
					numRed = numRed + 1
				end
			else
				v:Spawn()
				v:SetPos(spawnBlue[numBlue]:GetPos())

				if spawnBlue[numBlue+1] == nil then
					numBlue = 1
				elseif spawnBlue[numBlue+1]:GetPos() == nil then
					numBlue = 1
				else
					numBlue = numBlue + 1
				end
			end
		end
	end

end)

hook.Add("RoundEnd", "TVA_KillTimer", function()
	pickedLastRound_1 = picked_1

	if !table.HasValue(Minigames.OneVersusAll, game.GetMap()) then
		pickedLastRound_2 = picked_2
	end

	for k, v in pairs(player.GetAll()) do
		if v:Team() == TEAM_RED then
			v:SetTeam(TEAM_BLUE)
		end

		v:KillSilent()
	end
	timer.Destroy("CheckTSAEnd")
end)

hook.Add("PlayerSpawn", "Speed_TVS", function(ply)
	ply:SetWalkSpeed(Minigames.TwoVersusAll.WalkSpeed)
	ply:SetRunSpeed(Minigames.TwoVersusAll.RunSpeed)
end)

hook.Add("PlayerShouldTakeDamage", "TDM_TS", function(ply,attacker)
	if (attacker:IsPlayer() and ply:IsPlayer() and attacker:Team() == ply:Team()) and attacker != ply then
		return false
	end
end)
