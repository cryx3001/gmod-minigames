-- ROUND NOTIFICATIONS
MG_MvpPlayer = nil
net.Receive("MG_SendMVPPlayer", function()
	MG_MvpPlayer = net.ReadEntity()
end)

net.Receive("Minigames_NotifyRound", function()
	local number = tonumber(net.ReadString())
	local winner = tonumber(net.ReadString())
	local winner_nick = net.ReadString()
	local mvpPly = net.ReadEntity() or nil
	local mvpArg = net.ReadString() or ""
	local tauntID = net.ReadInt(11)
	local colorFrameOne
	local colorFrameTwo
	--print(winner)


	Minigames.RoundState = number

	if number != 1 then
		if timer.Exists("MinigamesRoundTimer") then
			timer.Destroy("MinigamesRoundTimer")
		end
	else
		timer.Create("MinigamesRoundTimer", GetGlobalInt("Minigames_RoundTime"), 1, function()
			timer.Destroy("MinigamesRoundTimer")
		end)
	end

	if number == 0 then
		local time = 0
		if Minigames.RoundNumber < 1 then
			time = Minigames.InitialPreRound
		else
			time = Minigames.PreRound
		end

		if time != 0 then
			chat.AddText(Color(255,0,102), "[MINIGAMES] ", Color(255,255,255), "Be ready, the round is starting in ", Color(67,191,227), time .. " seconds", Color(255,255,255), ".")
		end

	elseif number == 1 then
		chat.AddText(Color(255,0,102), "[MINIGAMES] ", Color(255,255,255), "You're playing ", Color(67,191,227), Minigames:ReturnGamemodeString(), Color(255,255,255), " ! Press F1 for more info.")

	elseif number == 2 then
		Minigames.RoundNumber = Minigames.RoundNumber + 1

		if winner == 0 then
			chat.AddText(Color(255,0,102), "[MINIGAMES] ", Color(255,255,255), "Round end! The timer has reached his limit.")
		elseif winner == 1 then
			chat.AddText(Color(255,0,102), "[MINIGAMES] ", Color(255,255,255), "Round end! The winner is ", Color(255,0,102), winner_nick, Color(255,255,255), "!" )
		elseif winner == TEAM_BLUE then
			chat.AddText(Color(255,0,102), "[MINIGAMES] ", Color(255,255,255), "Round end! The winner is the", Color(67,191,227), " Blue Team ", Color(255,255,255), "!" )
		elseif winner == TEAM_RED then
			chat.AddText(Color(255,0,102), "[MINIGAMES] ", Color(255,255,255), "Round end! The winner is the", Color(255,0,0), " Red Team ", Color(255,255,255), "!" )
		elseif winner == 4 then
			chat.AddText(Color(255,0,102), "[MINIGAMES] ", Color(255,255,255), "Draw! Nobody wins." )
		end
	end

	if number == 2 then
		if winner == TEAM_BLUE then
			colorFrameOne = Color(0,1,82,120)
			colorFrameTwo = Color(0,1,82,50)
		elseif winner == TEAM_RED then
			colorFrameOne = Color(75,0,0,120)
			colorFrameTwo = Color(75,0,0,50)
		else
			colorFrameOne = Color(0, 0, 0, 120)
			colorFrameTwo = Color(0, 0, 0, 90)
		end


		local frame = vgui.Create("DFrame")
		frame:SetSize(512+128,64+64+16)
		frame:ShowCloseButton(false)
		frame:SetTitle("")
		frame:SetPos(ScrW()/2-frame:GetWide()/2, ScrH()/5)
		frame.Paint = function()
			draw.RoundedBox(0, 0, 0,frame:GetWide(),frame:GetTall(),colorFrameTwo)

			if mvpPly then
				if mvpPly:IsPlayer() and mvpArg and mvpPly:Name() and mvpPly:IsValid() then
					if mvpArg == "KILLS" then
						draw.DrawText("MVP: "..mvpPly:Name().." for most eliminations","NexaLight25", 64+8, 64, Color(240,240,240,255), TEXT_ALIGN_LEFT)
					elseif mvpArg == "DMG" then
						draw.DrawText("MVP: "..mvpPly:Name().." for most damage dealt.", "NexaLight25", 64+8, 64, Color(240,240,240,255), TEXT_ALIGN_LEFT)
					elseif mvpArg == "TIME" then
						draw.DrawText("MVP: "..mvpPly:Name().." for surviving the longest time.", "NexaLight25", 64+8, 64, Color(240,240,240,255), TEXT_ALIGN_LEFT)
					else
						draw.DrawText("MVP: "..mvpPly:Name().." (ERROR)", "NexaLight25", 64+8, 64, Color(240,240,240,255), TEXT_ALIGN_LEFT)
					end
				end

				if tauntID != -1 and tauntID != nil and mvpPly:IsPlayer() and mvpArg then
					draw.DrawText(MG_Taunts[tauntID]["Name"],"NexaLight25",64+32, 100, Color(240,240,240,255), TEXT_ALIGN_LEFT)
				end
			end
		end



		if mvpPly:IsPlayer() and mvpArg and mvpPly:IsValid() then
			local avatarPly = vgui.Create( "AvatarImage", frame )
			avatarPly:SetSize( 64, 64 )
			avatarPly:SetPos( 4, 64 )
			avatarPly:SetPlayer( mvpPly, 64 )
		end

		if tauntID != -1 and tauntID != nil and mvpPly:IsPlayer() and mvpArg then
			surface.PlaySound(MG_Taunts[tauntID]["Path"])

			local imageSound = vgui.Create("DImage", frame)
	        imageSound:SetSize(16,16)
	        imageSound:SetPos(72,106)
	        imageSound:SetImage("icon16/sound")
		end

		local winframe = vgui.Create("DFrame", frame)
		winframe:SetSize(512+128,32+16)
		winframe:ShowCloseButton(false)
		winframe:SetTitle("")
		winframe:SetPos(0,0)
		winframe.Paint = function()
			draw.RoundedBox(0, 0, 0,winframe:GetWide(),winframe:GetTall(),colorFrameOne)

			if winner == TEAM_RED then
				draw.DrawText("The Red Team won!","NexaLight40", winframe:GetWide()/2, 5, Color(200,200,200,255), TEXT_ALIGN_CENTER)
			elseif winner == TEAM_BLUE then
				draw.DrawText("The Blue Team won!","NexaLight40", winframe:GetWide()/2, 5, Color(200,200,200,255), TEXT_ALIGN_CENTER)
			elseif winner == 4 then
				draw.DrawText("Draw! Nobody wins.","NexaLight40", winframe:GetWide()/2, 5, Color(200,200,200,255), TEXT_ALIGN_CENTER)
			elseif winner == 1 and winner_nick then
				draw.DrawText("Our winner is "..winner_nick.."!","NexaLight40", winframe:GetWide()/2, 5, Color(200,200,200,255), TEXT_ALIGN_CENTER)
			elseif winner == 0 then
				draw.DrawText("The timer has reached his limit.","NexaLight40", winframe:GetWide()/2, 5, Color(200,200,200,255), TEXT_ALIGN_CENTER)
			end
		end

		timer.Simple(Minigames.EndOfRoundTime-0.1,function() frame:Remove() end)
	end
end)

--[[ KILLING
net.Receive("Minigames_PointsOnKill", function()
	local attacker = net.ReadString()
	local ply = net.ReadString()

	chat.AddText(Color(255,0,102), "[MINIGAMES] ", Color(255,255,255), "Tu as reçu ", Color(67,191,227), Minigames.PointsPerKill .. " points ", Color(255,255,255), "pour avoir tué ", Color(67,191,227), ply, Color(255,255,255), "!")
end)
--]]


net.Receive("MG_NotifyTeamBalance", function()
	local ply = net.ReadString()
	local moved = net.ReadString()

	local strng = nil
	if moved == "2" then
		strng = "Blue"
	else
		strng = "Red"
	end

	chat.AddText(Color(255,0,102), "[MINIGAMES] ", Color(67,191,227),ply, Color(255,255,255), " has been moved ",  Color(67,191,227), "in Team " .. strng, Color(255,255,255), " for balance!")
end)

--]]

net.Receive("CTF_FlagToggle", function()
	local toggle = net.ReadBool()
	local ply = net.ReadString()
	local flag = tonumber(net.ReadString())

	local teamstring = "Blue Team"
	if flag == 3 then
		teamstring = "Red Team"
	end

	if toggle then
		chat.AddText(Color(255,0,102), "[MINIGAMES] ", Color(67,191,227), ply, Color(255,255,255), " a pris de ", Color(67,191,227),teamstring, Color(255,255,255), " leur drapeau!")
	/*
	else
		chat.AddText(Color(255,0,102), "[MINIGAMES] ", Color(67,191,227), teamstring, Color(255,255,255), "Drapeau est tombé! Reset dans", Color(61,191,227), tostring(Minigames.CaptureTheFlag.FlagReset), Color(255,255,255), " seconds!")
	*/
	end
end)

net.Receive("CTF_Reset", function()
	local flag = tonumber(net.ReadString())

	local teamstring = "Blue Team"
	if flag == 3 then
		teamstring = "Red Team"
	end

	chat.AddText(Color(255,0,102), "[MINIGAMES] ", Color(67,191,227), teamstring, Color(255,255,255), "Drapeau a été reset")
end)

net.Receive("TVA_AutoBalance", function()
	local playerConcerned = net.ReadString()
	chat.AddText(Color(255,0,102), "[MINIGAMES] ", Color(67,191,227), playerConcerned, Color(255,255,255), " has been moved to the other team for waiting for a third player")
end)

net.Receive("CTF_Capt", function()
	local flag = tonumber(net.ReadString())

	local teamstring = "Blue Team"
	if flag == 3 then
		teamstring = "Red Team"
	end

	chat.AddText(Color(255,0,102), "[MINIGAMES] ", Color(67,191,227), teamstring, Color(255,255,255), " has captured the flag")
end)

net.Receive("CTF_SendCaptures", function()
	Minigames.BlueCaps = net.ReadString()
	Minigames.RedCaps = net.ReadString()
end)

net.Receive("CTF_AddCapture", function()
	local team_add = net.ReadString()

	if team_add == "blue" then
		Minigames.BlueCaps = Minigames.BlueCaps + 1
	else
		Minigames.RedCaps = Minigames.RedCaps + 1
	end
end)

net.Receive("MG_DisplayWinner", function()
	local winning_key = net.ReadString()

	chat.AddText(Color(255,0,102), "[MINIGAMES] ", Color(255,255,255), "The gamemode has been chosen! The winner is ", Color(67,191,227), winning_key, Color(255,255,255), " !")
end)

net.Receive("Minigames_NotifyRTV", function()
	local user = net.ReadString()
	local state = net.ReadString()
	local plyNeeded = net.ReadString()

	if state == "voting" then
		chat.AddText(Color(255,0,102), "[MINIGAMES] ", Color(67,191,227), user, Color(255,255,255), " wants to RTV ! Type ", Color(67,191,227), "/rtv", Color(255,255,255), " to get a mapvote. "..plyNeeded.." more players needed.")
	elseif state == "failed" then
		chat.AddText(Color(255,0,102), "[MINIGAMES] ", Color(255,255,255), "RTV failed! Not enough people asked for it.")
	elseif state == "success" then
		chat.AddText(Color(255,0,102), "[MINIGAMES] ", Color(255,255,255), "RTV succeeded! The mapvote will show up at the end of the round.")
	end
end)

net.Receive("MG_SendInitalData", function()
	Minigames.RoundNumber = tonumber(net.ReadString())
	Minigames.RoundLimit = tonumber(net.ReadString())

end)


net.Receive("Team_Select", function()
	Minigames:SelectTeams()
end)


net.Receive("MG_NotifyScramble", function()
	local ply = net.ReadString()

	chat.AddText(Color(255,0,102), "[MINIGAMES] ", Color(67,191,227), ply, Color(255,255,255), " has shuffled teams")
end)

net.Receive("Minigames_PlyConnected", function()
	local name = net.ReadString()
	local steamID = net.ReadString()
	chat.AddText(Color(112, 174, 255), name, Color(255,255,255), " has connected.  ("..steamID..")")
end)

net.Receive("Minigames_PlyDisconnected", function()
	local name = net.ReadString()
	local steamID = net.ReadString()
	chat.AddText(Color(112, 174, 255), name, Color(255,255,255), " has disconnected.  ("..steamID..")")
end)
