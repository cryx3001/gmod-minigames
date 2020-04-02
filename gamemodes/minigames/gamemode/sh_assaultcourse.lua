MG_isOneTeam = true

hook.Add("PlayerInitialSpawn", "AC_SetTeam", function(ply)
	ply:SetTeam(TEAM_BLUE)
end)

hook.Add("PlayerSpawn", "Speed_AC", function(ply)
	ply:SetWalkSpeed(Minigames.AssaultCourse.WalkSpeed)
	ply:SetWalkSpeed(Minigames.AssaultCourse.RunSpeed)
	ply:Give("weapon_knife")

	if game.GetMap() == "mg_saw_iv" then
		ply:GodEnable()
		timer.Simple(3,function() ply:GodDisable() end)
	end
end)

function Minigames:PlayedStoppedSpectating(ply)
	ply:SetTeam(TEAM_BLUE)
end

function Minigames:PlayerJoinedPreRound(ply)
	ply:Spawn()
end

function Minigames:PlayerConnectedPreround(ply)
	if not ply:IsPlayingGame() then
		ply:SetTeam(TEAM_BLUE)
	end

	if not ply:Alive() then
		ply:Spawn()
	end
end

function Minigames:CanStartGame()
	if #team.GetPlayers(TEAM_BLUE) >= 1 then
		return true
	end
end

hook.Add("RoundBegin", "AC_Begin", function()
	timer.Create("CheckDeaths", 0.5, 0, function()
		Minigames:CheckACDeaths()
	end)
end)

hook.Add("RoundEnd", "AC_RO", function(winner)
	timer.Destroy("CheckDeaths")
end)

hook.Add("PlayerShouldTakeDamage", "AC_Null", function(ply,attacker)
	if attacker:IsPlayer() and ply:IsPlayer() and attacker ~= ply then
		return false
	end

end)

function Minigames:CheckACDeaths()

	if Minigames.RoundState ~= 1 then return end

	if #player.GetActive() < 1 then
		Minigames:RoundEnd(4)
	end
end

-- AFK Kicker

AFK_WARN_TIME = 20 --Le nb de secondes avant de mourrir
AFK_TIME = 40

hook.Add("PlayerSpawn", "MakeAFKVar", function(ply)
	ply.NextAFK = CurTime() + AFK_TIME
end)

hook.Add("Think", "HandleAFKPlayers", function()
	for _, ply in pairs(player.GetAll()) do
		if ply:Alive() then
			ply.LastWarningState = nil
			if ( ply:IsConnected() and ply:IsFullyAuthenticated() ) then
				if (!ply.NextAFK) then
					ply.NextAFK = CurTime() + AFK_TIME
				end

				if ply:IsTyping() then
					ply.NextAFK = CurTime() + AFK_TIME
					if ply.Warning == true then
						ply.Warning = false
						ply:ChatPrint("You're not AFK anymore!")
					end
				end

				ply.afktime = ply.NextAFK
				if (CurTime() >= ply.afktime - AFK_WARN_TIME) and (!ply.Warning) then
					ply:ChatPrint("Warning! You're AFK !")
					ply:ChatPrint("You will be slayed in "..(AFK_WARN_TIME).." seconds if you don't play.")
					ply.Warning = true

				elseif (CurTime() >= ply.afktime) and (ply.Warning) and ply:Alive() then --Tps dépassé, on le suicide
					ply.Warning = nil
					ply.NextAFK = nil
					ply:Kill()
					ply:ChatPrint("You have been slayed, due to being AFK!")
				end
			end
		else
			ply.NextAFK = nil
		end

	end
end)

hook.Add("KeyPress", "PlayerMoved", function(ply, key)
	ply.NextAFK = CurTime() + AFK_TIME
	if ply.Warning == true then
		ply.Warning = false

		ply:ChatPrint("You're not AFK anymore!")
	end
end)
