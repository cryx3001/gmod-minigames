local isPreRound
local MG_IsRTVRequestAccepted
MG_CANDROPWEAPON = nil

function Minigames:LoadTeddy()
	local mapfile = file.Exists("data/minigames/" .. game.GetMap() .. ".txt", "GAME")

	if mapfile then
		local read = file.Read("minigames/" .. game.GetMap() .. ".txt")

		local split_1 = string.Split(read, "/")
		local pos = split_1[1]
		local ang = split_1[2]

		local teddy = ents.Create("ac_teddy")
		teddy:SetPos(Vector(pos))
		teddy:SetAngles(Angle(ang))
		teddy:Spawn()
	end
end

function Minigames:CanStartGame()
	if #team.GetPlayers(TEAM_BLUE) >= 2 then
		return true
	end

	return false
end

function Minigames:PlayerJoinedDuringRound(ply)
end

function Minigames:PlayerJoinedPreRound(ply)
	ply:SetJumpPower(220)
end

function Minigames:CheckForPlayers()

	if not Minigames:CanStartGame() then
		timer.Simple(2, function()
			Minigames:CheckForPlayers()
		end)
	else
		Minigames:PreRoundBegin()
	end

end

--

function Minigames:PreRoundBegin()
	if Minigames.RoundState == 0 then return end
	game.CleanUpMap()
	local timeos = tostring(os.date( "%H:%M:%S - %d/%m/%Y" , os.time()))

	if GetConVar("phys_pushscale"):GetInt() != 1 then
		RunConsoleCommand("phys_pushscale","1")
	end

	if Minigames:CanStartGame() then
		isPreRound = true

		for k, v in pairs(player.GetAll()) do v:StripWeapons() end
		Minigames.RoundState = 0

		net.Start("Minigames_NotifyRound")
			net.WriteString(Minigames.RoundState)
		net.Broadcast()



		for k, v in pairs(player.GetAll()) do
			if v:IsPlayingGame() then
				Minigames:PreRoundPlayers(v)
				v:SetJumpPower(220)
			end
		end

		if GhostMode then
			for k, v in pairs(player.GetAll()) do
				if v:IsGhostMode() then
					GhostMode:ToggleGhostMode(v)
					v:Spawn()
				end
			end
		end

		local time = 0
		if Minigames.RoundNumber < 1 then
			time = Minigames.InitialPreRound
		else
			time = Minigames.PreRound
		end

		timer.Create("RoundBeginTimer",time, 1, function()
			for k, v in pairs(player.GetAll()) do v:StripWeapons() end
			Minigames:RoundBegin()
			timer.Destroy("RoundBeginTimer")
		end)

		--print(timer.TimeLeft("RoundBeginTimer"))

		net.Start("MG_SendTimerPreRound")
		net.WriteFloat(timer.TimeLeft("RoundBeginTimer"))
		net.WriteFloat(CurTime())
		net.Broadcast()


		game.CleanUpMap()
		hook.Call("PreRoundBegin", GAMEMODE)
		Minigames.RoundNumber = Minigames.RoundNumber + 1
	else
		Minigames:CheckForPlayers()
	end
end

function Minigames:PreRoundPlayers(ply)
	if ply:Team() == TEAM_RED or ply:Team() == TEAM_BLUE then
		ply:SetModel(ply.PlayerModel or "models/player/gasmask.mdl")
		ply:Spawn()
		ply:SetJumpPower(220)
		ply:SetMoveType(MOVETYPE_WALK)
	end

	hook.Call("PreRoundPlayer", GAMEMODE, ply)
end

function Minigames:RoundBegin()
	if Minigames.RoundState == 1 then return end
	Minigames.RoundState = 1

	if Minigames.RoundNumber == 1 then
		game.CleanUpMap()
	end

	MG_CANDROPWEAPON = true
	Minigames:LoadTeddy()

	if SERVER then
		isPreRound = false
		net.Start("Minigames_NotifyRound")
			net.WriteString(Minigames.RoundState)
		net.Broadcast()

		for k, v in pairs(player.GetAll()) do
			if v:IsPlayingGame() then
				v:SetJumpPower(220)
				Minigames:RoundPlayers(v)
			end
		end
	end

	timer.Create("MinigamasesRoundTimer", GetGlobalInt("Minigames_RoundTime"), 1, function()
		Minigames:RoundEnd()
		timer.Destroy("MinigamesRoundTimer")
	end)

	hook.Call("RoundBegin", GAMEMODE)

	timer.Simple(5, function()
		if cvars.Number("sv_gravity") == 800 then
			RunConsoleCommand("sv_gravity",600)
		end

		if cvars.Number("sv_accelerate") < 10 then
			RunConsoleCommand("sv_accelerate",10)
		end
	end)
end

function Minigames:RoundPlayers(ply)
	ply:SetJumpPower(220)
	if ply:Team() == TEAM_RED or ply:Team() == TEAM_BLUE then
		ply:Spawn()
	end

	hook.Call("RoundPlayer", GAMEMODE, ply)
end


function Minigames:RoundEnd(state_id, winnernick)
	if Minigames.RoundState == 2 then return end
	MG_WinnerTeamReturn = state_id

	if cvars.Number("sv_gravity") != 600 then
		RunConsoleCommand("sv_gravity",600)
	end

	if cvars.Number("sv_accelerate") != 10 then
		RunConsoleCommand("sv_accelerate",10)
	end

	if cvars.Number("sv_airaccelerate") != 150 then
		RunConsoleCommand("sv_airaccelerate", 150)
	end


	for k, v in pairs(player.GetActive()) do
		v:SetFOV(0,0.3)
		v:StripWeapons()
		v:SetJumpPower(220)
	end

	Minigames.RoundState = 2

	if not state_id then
		state_id = 0
	end

	winnernick = winnernick or ""

	local tblMvp = MG_CheckMVPPlayerEnd()

	net.Start("Minigames_NotifyRound")
		net.WriteString(Minigames.RoundState)
		net.WriteString(state_id)
		net.WriteString(winnernick)
		if tblMvp[1] and tblMvp[2] then
			net.WriteEntity(tblMvp[1])
			net.WriteString(tblMvp[2])
			net.WriteInt(tblMvp[1].equippedTaunt or -1, 11)
		end
	net.Broadcast()


	hook.Call("RoundEnd", GAMEMODE, state_id)

	if Minigames.RoundNumber < Minigames.RoundLimit then
		timer.Simple(Minigames.EndOfRoundTime, function()
			MG_ShuffleTeam()
			Minigames:PreRoundBegin()
		end)
	else
		Minigames:LoadGamemodeVotes()
		hook.Call("VotingBegin", GAMEMODE, nil)
	end

end

function Minigames:PlayerRequestedRTV(ply)
	if not Minigames.CanRTV then return end
	if MG_IsRTVRequestAccepted then return end

	local playersNeeded = (math.Round(#player.GetAll()/Minigames.RTVPercentage) - #Minigames.RTVUsers) - 1
	playersNeeded = tostring(playersNeeded)

	if not Minigames.ActiveRTV then

		if Minigames.Cooldown and Minigames.Cooldown > CurTime() then
			ply:ChatPrint("Sorry, but you will have to wait to do that.")
			return
		end

		Minigames.ActiveRTV = true
	end


	if table.HasValue(Minigames.RTVUsers, ply) then
		ply:ChatPrint("Sorry ! You have already voted !")
	else

		net.Start("Minigames_NotifyRTV")
			net.WriteString(ply:Nick())
			net.WriteString("voting")
			net.WriteString(playersNeeded)
		net.Broadcast()
		table.insert(Minigames.RTVUsers, ply)
		if #Minigames.RTVUsers >= math.Round(#player.GetAll()/Minigames.RTVPercentage) then
			timer.Destroy("Minigames_CheckRTV")
			Minigames:RTVHasFinished(true)
		end
	end
end

function Minigames:RTVHasFinished(bool)
	if not Minigames.ActiveRTV then return end
	Minigames.RTVUsers = {}
	Minigames.ActiveRTV = false
	local playersNeeded = math.Round(#player.GetAll()/Minigames.RTVPercentage) - #Minigames.RTVUsers
	playersNeeded = tostring(playersNeeded)


	if bool then
		MG_IsRTVRequestAccepted = true
		if Minigames.RoundState == 1 then
			Minigames.RoundNumber = Minigames.RoundLimit
		else
			timer.Simple(3, function()
				Minigames:LoadGamemodeVotes()
			end)
		end
		net.Start("Minigames_NotifyRTV")
			net.WriteString("")
			net.WriteString("success")
			net.WriteString(playersNeeded)
		net.Broadcast()
	else
		MG_IsRTVRequestAccepted = false
		net.Start("Minigames_NotifyRTV")
			net.WriteString("")
			net.WriteString("failed")
			net.WriteString(playersNeeded)
		net.Broadcast()
		Minigames.Cooldown = CurTime() + Minigames.RTVCooldown
	end
end

function Minigames:ReturnWinnerTeam()
	if #Minigames:ReturnBlueAlive() <= 0 and #Minigames:ReturnRedAlive() > 0 then
		return 3 --  Rouge gagne
	elseif #Minigames:ReturnBlueAlive() > 0 and #Minigames:ReturnRedAlive() <= 0 then
		return 2 --Bleu gagne
	end
end

hook.Add("RoundEnd", "GivePSPointWhenEnd", function()
	if Minigames:IsPlayingFreeForAll() or Minigames:IsPlayingAssaultCourse() then
		for k, v in pairs(player.GetAll()) do
			if v:Alive() then v:SH_AddStandardPoints(20) end
		end

	else
		if MG_WinnerTeamReturn == TEAM_RED then
			for k, v in pairs(player.GetAll()) do
				if v:Team() == TEAM_RED then v:SH_AddStandardPoints(5) end
			end

		elseif MG_WinnerTeamReturn == TEAM_BLUE then
			for k, v in pairs(player.GetAll()) do
				if v:Team() == TEAM_BLUE then v:SH_AddStandardPoints(5) end
			end
		end

	end
end)

function Minigames:CheckWinningTeam()
	if Minigames.RoundState ~= 1 then return end
	if #Minigames:ReturnBlueAlive() <= 0 and #Minigames:ReturnRedAlive() > 0 then
		Minigames:RoundEnd(TEAM_RED)
	elseif #Minigames:ReturnBlueAlive() > 0 and #Minigames:ReturnRedAlive() <= 0 then
		Minigames:RoundEnd(TEAM_BLUE)
	elseif #Minigames:ReturnBlueAlive() <= 0 and #Minigames:ReturnRedAlive() <= 0 then
		Minigames:RoundEnd(4)
	end

end

local autobalance_cooldown = nil
function Minigames:CheckAutobalance()

	if autobalance_cooldown and autobalance_cooldown > CurTime() then return end

	local highest_team = nil
	local lowest_team = nil
	if #team.GetPlayers(TEAM_BLUE) == 1 and #team.GetPlayers(TEAM_RED)== 1 then return end

	if #team.GetPlayers(TEAM_BLUE) > #team.GetPlayers(TEAM_RED) then
		highest_team = 2
		lowest_team = 3
	elseif #team.GetPlayers(TEAM_RED) > #team.GetPlayers(TEAM_BLUE) then
		highest_team = 3
		lowest_team = 2
	end

	if not highest_team and not lowest_team then return end

	local swaps = false
	local difference = (#team.GetPlayers(highest_team)) - (#team.GetPlayers(lowest_team))
	if difference > 1 then
		swaps = true
	end

	if swaps then
		local score = 999
		local lowest_scoring = nil
		for k, v in pairs(team.GetPlayers(highest_team)) do
			if v:Frags() < score then
				score = v:Frags()
				lowest_scoring = v
			end
		end
		autobalance_cooldown = CurTime() + 2
		lowest_scoring:SetTeam(lowest_team)
		lowest_scoring:Kill()
		timer.Simple(1, function()
		lowest_scoring:Spawn()
		end)
		net.Start("MG_NotifyTeamBalance")
			net.WriteString(lowest_scoring:Nick())
			net.WriteString(lowest_team)
		net.Broadcast()
	end

end
