hook.Add("PlayerSay", "Minigames_ChatHooks", function(ply,text,teamonly)

	if text == "/forcevote" then
		if table.HasValue(Minigames.AdminGroups,ply:GetUserGroup()) then
			Minigames:RoundEnd(nil,nil)
			Minigames:LoadGamemodeVotes()
		else
			Minigames:DenyAccess(ply)
		end
	elseif text == "/help" then
		net.Start("F_Help")
		net.Send(ply)
	elseif text == "/teams" then
		Minigames:ShowTeamSelect(ply)
	elseif text == "/rtv" then
		if Minigames.DefaultMapvote then
			Minigames:PlayerRequestedRTV(ply)
		end
	elseif text == "/scramble" then
		if table.HasValue(Minigames.AdminGroups,ply:GetUserGroup()) then
			Minigames:ScrambleTeams(ply)
		end
	elseif text == "/models" then
		print("Test0")
	    net.Start("MG_ShowPanelPlayerModel")
		net.Send(ply)

	elseif text == "/roundend" then
		if table.HasValue(Minigames.AdminGroups,ply:GetUserGroup()) then
			Minigames:RoundEnd(nil)
		end
	end
end)

function Minigames:ScrambleTeams(ply)
	if Minigames:IsPlayingFreeForAll() or Minigames:IsPlayingAssaultCourse() then return end

	if #player.GetActive() < 4 then
		ply:ChatPrint("Sorry! You need 4 players to scramble teams.")
	else
		local redtbl = {}
		local bluetbl = {}

		local redcount = #team.GetPlayers(TEAM_RED)
		local bluecount = #team.GetPlayers(TEAM_BLUE)

		while #redtbl < redcount/2 do
			local random = table.Random(team.GetPlayers(TEAM_RED))

			if not table.HasValue(redtbl,random) then
				table.insert(redtbl,random)
			end

		end

		while #bluetbl < bluecount/2 do
			local random = table.Random(team.GetPlayers(TEAM_BLUE))

			if not table.HasValue(bluetbl,random) then
				table.insert(bluetbl,random)
			end

		end

		for k, v in pairs(bluetbl) do
			v:SetTeam(3)
			v:KillSilent()
			v:Spawn()
		end

		for k, v in pairs(redtbl) do
			v:SetTeam(2)
			v:KillSilent()
			v:Spawn()
		end

		net.Start("MG_NotifyScramble")
			net.WriteString(ply:Nick())
		net.Broadcast()
	end
end

function Minigames:DenyAccess(ply)
	ply:ChatPrint("[MINIGAMES] Sorry! You're not allowed to do that.")
end

function Minigames:SetAFK(ply)
	if ply:Team() ~= TEAM_SPECTATOR then
		ply:KillSilent()
		ply:StripWeapons()
		ply:SetTeam(TEAM_SPECTATOR)
		ply:SetMoveType(MOVETYPE_NOCLIP)
		ply:ChatPrint("You have been moved to spectators.")
		net.Start("Minigames_AvatarHUD")
			net.WriteBool(false)
		net.Send(ply)
	else
		Minigames:PlayedStoppedSpectating(ply)
	end
end
