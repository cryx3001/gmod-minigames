function GM:ScoreboardShow()
	if Minigames.DefaultScoreboard then
		Minigames:ShowScoreboard()
	end
end

function GM:ScoreboardHide()
	if Minigames.DefaultScoreboard then
		Minigames:HideScoreboard()
		gui.EnableScreenClicker(false)
	end
end

function Minigames:GetSpecsNGhosts()
	local tbl = {}
	for k, v in pairs(player.GetAll()) do
		if v:Team() ~= TEAM_BLUE then
			if v:Team() ~= TEAM_RED then
				table.insert(tbl,v)
			end
		end
	end

	return tbl
end
Minigames.ScoreboardOpen = false


function Minigames:ShowScoreboard()
	Minigames.ScoreboardOpen = true

	local plyWantedToSee = LocalPlayer()

	local spacing = 20
	local frame = vgui.Create("DFrame")
	frame:SetSize(1024,ScrH())
	frame:SetPos(0,0)
	frame:Center()
	frame:ShowCloseButton(false)
	frame:SetTitle("")
	frame.Paint = function()
		--draw.RoundedBox(0,0,0,frame:GetWide(),frame:GetTall(),Color(255,0,0,100))
	end

	frame:OnMousePressed(107)
	frame.Think = function()
		gui.EnableScreenClicker(true)
	end


	local host_dpanel = vgui.Create("DPanel", frame)
	host_dpanel:SetSize(700,50)
	host_dpanel:SetPos(0,0)
	host_dpanel.Paint = function()
		/*
		draw.RoundedBox(0,0,0,host_dpanel:GetWide(),host_dpanel:GetTall(),Color(0,0,0,100))
		draw.DrawText(GetHostName(), "NexaLight35",host_dpanel:GetWide()/2,5, Color(255, 255, 255, 255),TEXT_ALIGN_CENTER)
		*/
	end

	local space = #Minigames.SBT*64+5*#Minigames.SBT+7
	local height = frame:GetTall()-spacing-spacing-spacing-74-50-50-50

	local team_2_header = vgui.Create("DPanel", frame)
	team_2_header:SetSize(500, 50)

	team_2_header:SetPos(0,host_dpanel:GetTall()+spacing)
	team_2_header.Paint = function()
		/*
		draw.RoundedBox(0,0,0,team_2_header:GetWide(),team_2_header:GetTall(),Color(0,0,0,100))
		draw.DrawText("Blue Team", "NexaLight35",5,10, Color(255, 255, 255, 255),TEXT_ALIGN_LEFT)
		-- draw.DrawText(team.GetScore(TEAM_BLUE), "NexaLight40",team_2_header:GetWide()-5,7, Color(255, 255, 255, 255),TEXT_ALIGN_RIGHT)
		*/
	end

	local team_2_panel = vgui.Create("DPanel", frame) -- GROS RECTANGLE
		team_2_panel:SetPos(0,host_dpanel:GetTall()+team_2_header:GetTall()+spacing)
		team_2_panel:SetSize(team_2_header:GetWide(),26)
		team_2_panel.Paint = function()
			draw.RoundedBox(0,0,0,team_2_panel:GetWide(),team_2_panel:GetTall(),Color(0, 0, 0,180))
			draw.DrawText("NICKNAME", "NexaLight20",58,5, Color(255, 255, 255, 255),TEXT_ALIGN_LEFT)
			--draw.DrawText("RANK", "NexaLight20",team_2_panel:GetWide()-320,5, Color(255, 255, 255, 255),TEXT_ALIGN_CENTER)
			draw.DrawText("LEVEL", "NexaLight20",team_2_panel:GetWide()-240,5, Color(255, 255, 255, 255),TEXT_ALIGN_CENTER)
			draw.DrawText("KILLS", "NexaLight20",team_2_panel:GetWide()-170,5, Color(255, 255, 255, 255),TEXT_ALIGN_CENTER)
			draw.DrawText("DEATHS", "NexaLight20",team_2_panel:GetWide()-100,5, Color(255, 255, 255, 255),TEXT_ALIGN_CENTER)
			draw.DrawText("PING", "NexaLight20",team_2_panel:GetWide()-30,5, Color(255, 255, 255, 255),TEXT_ALIGN_CENTER)
			draw.RoundedBox(0,0,25,team_2_panel:GetWide(),1,Color(255,255,255,150))
		end

	local team_2_scroll = vgui.Create("DScrollPanel", frame)
	team_2_scroll:SetPos(0,host_dpanel:GetTall()+team_2_header:GetTall()+spacing+26)
	team_2_scroll:SetSize(team_2_header:GetWide(),height-26)
	team_2_scroll.Paint = function()
		draw.RoundedBox(0,0,0,team_2_scroll:GetWide(),team_2_scroll:GetTall(),Color(20,20,20,150))
	end

	local statsPanel = vgui.Create("DPanel", frame)
	statsPanel:SetPos(frame:GetWide()-450, team_2_header:GetTall()+70)
	statsPanel:SetSize(450,team_2_scroll:GetTall()+team_2_header:GetTall()-24)

	local buttonPlayerSteam = vgui.Create("DButton", statsPanel)
	buttonPlayerSteam:SetText("")
	buttonPlayerSteam.DoClick = function()
		gui.OpenURL("https://steamcommunity.com/profiles/"..plyWantedToSee:SteamID64())
		LocalPlayer():ChatPrint("Redirected to the Steam account of "..plyWantedToSee:Name()..".")
	end
	buttonPlayerSteam:SizeToContents()
	buttonPlayerSteam:SetSize(100,32)
	buttonPlayerSteam:SetPos(20,680)
	buttonPlayerSteam.Paint = function()
		draw.RoundedBox(0,0,0,100,32,Color(50,50,60,255))
		draw.DrawText("PROFILE", "Trebuchet24", buttonPlayerSteam:GetWide()/2, 4, Color(150, 150, 150, 255),TEXT_ALIGN_CENTER)
	end


	local GetSteamID = vgui.Create("DButton", statsPanel)
	GetSteamID:SetText("")
	GetSteamID.DoClick = function()
		SetClipboardText(plyWantedToSee:SteamID())
		LocalPlayer():ChatPrint("Steam ID of "..plyWantedToSee:Name().." copied to clipboard! ("..plyWantedToSee:SteamID()..")")
	end
	GetSteamID:SizeToContents()
	GetSteamID:SetSize(100,32)
	GetSteamID:SetPos((statsPanel:GetWide()/2)-50,680)
	GetSteamID.Paint = function()
		draw.RoundedBox(0,0,0,100,32,Color(50,50,60,255))
		draw.DrawText("STEAM ID", "Trebuchet24", GetSteamID:GetWide()/2, 4, Color(150, 150, 150, 255),TEXT_ALIGN_CENTER)
	end


	local buttonPlayerMute = vgui.Create("DButton", statsPanel)
	buttonPlayerMute:SetText("")
	buttonPlayerMute.DoClick = function()
		if !plyWantedToSee:IsMuted() then
			plyWantedToSee:SetMuted(true)
			LocalPlayer():ChatPrint(plyWantedToSee:Name().. " muted.")
		else
			plyWantedToSee:SetMuted(false)
			LocalPlayer():ChatPrint(plyWantedToSee:Name().. " unmuted.")
		end
	end

	buttonPlayerMute:SizeToContents()
	buttonPlayerMute:SetSize(100,32)
	buttonPlayerMute:SetPos(statsPanel:GetWide()-120,680)
	buttonPlayerMute.Paint = function()
		local textMute
		if !plyWantedToSee:IsMuted() then
			textMute = "MUTE"
		else
			textMute = "UNMUTE"
		end

		draw.RoundedBox(0,0,0,100,32,Color(50,50,60,255))
		draw.DrawText(textMute, "Trebuchet24", buttonPlayerMute:GetWide()/2, 4, Color(150, 150, 150, 255),TEXT_ALIGN_CENTER)
	end

	statsPanel.Paint = function()
		local steamIdWantedToSee = plyWantedToSee:SteamID64()
		local kills = GLOBAL_PLAYERSTATS[steamIdWantedToSee.."_KILLS"]
		local deaths = GLOBAL_PLAYERSTATS[steamIdWantedToSee.."_DEATHS"]
		local roundsPlayed = GLOBAL_PLAYERSTATS[steamIdWantedToSee.."_PLAYED"]
		local roundsWon = GLOBAL_PLAYERSTATS[steamIdWantedToSee.."_WON"]
		local dmgReceived = GLOBAL_PLAYERSTATS[steamIdWantedToSee.."_RECEIVED"]
		local dmgGiven = GLOBAL_PLAYERSTATS[steamIdWantedToSee.."_GIVEN"]
		local shotTouched = GLOBAL_PLAYERSTATS[steamIdWantedToSee.."_TOUCHED"]
		local shotFired = GLOBAL_PLAYERSTATS[steamIdWantedToSee.."_FIRED"]
		local shotHs = GLOBAL_PLAYERSTATS[steamIdWantedToSee.."_HS"]
		local playerBySteamId64 = player.GetBySteamID64(steamIdWantedToSee)
		local psPoints = GLOBAL_PLAYERSTATS[steamIdWantedToSee.."_PSPOINT"]
		--print(playerBySteamId64:SH_GetStandardPoints())

		local KDRatio = math.Round(kills/deaths, 2)
		local WinRatio = tostring(math.Round(roundsWon / roundsPlayed, 2) * 100).."%"
		local HSRate = math.Round(shotHs/shotTouched, 2)*100

		local statsLevel = GLOBAL_LVLXPSTATS[steamIdWantedToSee.."_LVL"]
		local statsXp = GLOBAL_LVLXPSTATS[steamIdWantedToSee.."_XP"]
		local statsXpNeeded = GLOBAL_LVLXPSTATS[steamIdWantedToSee.."_XPNEEDED"]

		draw.RoundedBox(0,0,0,statsPanel:GetWide(),statsPanel:GetTall(),Color(20,20,20,150))

		local avatarPlyStats = vgui.Create( "AvatarImage", statsPanel )
		avatarPlyStats:SetSize( 64+32, 64+32 )
		avatarPlyStats:SetPos(10,10)
		avatarPlyStats:SetPlayer( plyWantedToSee, 64 )

		draw.DrawText(plyWantedToSee:Name(), "NexaLight40", 120, 10, Color(255, 255, 255, 255),TEXT_ALIGN_LEFT)
		draw.DrawText("Level ", "NexaLight30", 120, 55, Color(255, 255, 255, 255),TEXT_ALIGN_LEFT)
		draw.DrawText(statsLevel, "NexaLight35", 180, 52, Color(255, 255, 255, 255),TEXT_ALIGN_LEFT)

		draw.RoundedBox( 0,120,90, 175 , 15, Color(0,0,0,150))
		draw.RoundedBox( 0,120,90, (statsXp/statsXpNeeded)*175 , 15, Color(0, 191, 255 ,160))
		draw.DrawText(string.Comma(statsXp).."/"..string.Comma(statsXpNeeded) ,"NexaLight15", 210,90, Color(255, 255, 255), TEXT_ALIGN_CENTER )

		/*
		surface.SetMaterial(Material("icon16/status_online.png"))
		surface.DrawTexturedRect(0,0, 16, 16)
		*/

		draw.DrawText("KILLS", "NexaLight35", (statsPanel:GetWide()/4)*1, 140+10, Color(200, 200, 200, 255),TEXT_ALIGN_CENTER)
		draw.DrawText(string.Comma(kills), "NexaLight30", (statsPanel:GetWide()/4)*1, 180+10, Color(255, 255, 255, 255),TEXT_ALIGN_CENTER)

		draw.DrawText("DEATHS", "NexaLight35", (statsPanel:GetWide()/4)*3 , 140+10, Color(200, 200, 200, 255),TEXT_ALIGN_CENTER)
		draw.DrawText(string.Comma(deaths), "NexaLight30", (statsPanel:GetWide()/4)*3, 180+10, Color(255, 255, 255, 255),TEXT_ALIGN_CENTER)

		draw.DrawText("K/D", "NexaLight35", (statsPanel:GetWide()/4)*1 , 220+30, Color(200, 200, 200, 255),TEXT_ALIGN_CENTER)
		draw.DrawText(KDRatio, "NexaLight30", (statsPanel:GetWide()/4)*1, 260+30, Color(255, 255, 255, 255),TEXT_ALIGN_CENTER)

		draw.DrawText("HS RATE", "NexaLight35", (statsPanel:GetWide()/4)*3 , 220+30, Color(200, 200, 200, 255),TEXT_ALIGN_CENTER)
		draw.DrawText(HSRate.."%", "NexaLight30", (statsPanel:GetWide()/4)*3, 260+30, Color(255, 255, 255, 255),TEXT_ALIGN_CENTER)

		draw.DrawText("DMG. GIVEN", "NexaLight35", (statsPanel:GetWide()/4)*1 , 300+50, Color(200, 200, 200, 255),TEXT_ALIGN_CENTER)
		draw.DrawText(string.Comma(math.Round(dmgGiven/1000, 1)).."k", "NexaLight30", (statsPanel:GetWide()/4)*1, 340+50, Color(255, 255, 255, 255),TEXT_ALIGN_CENTER)

		draw.DrawText("DMG. RECEIVED", "NexaLight35", (statsPanel:GetWide()/4)*3 , 300+50, Color(200, 200, 200, 255),TEXT_ALIGN_CENTER)
		draw.DrawText(string.Comma(math.Round(dmgReceived/1000, 1)).."k", "NexaLight30", (statsPanel:GetWide()/4)*3, 340+50, Color(255, 255, 255, 255),TEXT_ALIGN_CENTER)

		draw.DrawText("ROUNDS PLAYED", "NexaLight35", (statsPanel:GetWide()/4)*1 , 380+70, Color(200, 200, 200, 255),TEXT_ALIGN_CENTER)
		draw.DrawText(string.Comma(roundsPlayed), "NexaLight30", (statsPanel:GetWide()/4)*1, 420+70, Color(255, 255, 255, 255),TEXT_ALIGN_CENTER)

		draw.DrawText("ROUNDS WON", "NexaLight35", (statsPanel:GetWide()/4)*3 , 380+70, Color(200, 200, 200, 255),TEXT_ALIGN_CENTER)
		draw.DrawText(string.Comma(roundsWon), "NexaLight30", (statsPanel:GetWide()/4)*3, 420+70, Color(255, 255, 255, 255),TEXT_ALIGN_CENTER)

		draw.DrawText("WIN RATE", "NexaLight35", (statsPanel:GetWide()/4)*2 , 460+90, Color(200, 200, 200, 255),TEXT_ALIGN_CENTER)
		draw.DrawText(WinRatio, "NexaLight30", (statsPanel:GetWide()/4)*2, 500+90, Color(255, 255, 255, 255),TEXT_ALIGN_CENTER)

		surface.SetDrawColor(255,255,255,255)
		surface.SetMaterial(Material("icon16/coins.png"))
		surface.DrawTexturedRect(420, 56, 24, 24)
		draw.DrawText(string.Comma(psPoints), "NexaLight30", 410, 55, Color(255, 255, 255, 255),TEXT_ALIGN_RIGHT)

		draw.DrawText("Click to show your cursor and see players stats", "NexaLight20", statsPanel:GetWide()/2, statsPanel:GetTall()-45, Color(255, 255, 255, 255),TEXT_ALIGN_CENTER)
		draw.DrawText("by clicking on them!", "NexaLight20", statsPanel:GetWide()/2, statsPanel:GetTall()-25, Color(255, 255, 255, 255),TEXT_ALIGN_CENTER)
	end

	local num = 0
	local tblPlayersPlaying = {}

	for k, v in pairs(player.GetAll()) do
		if v:Team() == TEAM_BLUE or v:Team() == TEAM_RED then
			tblPlayersPlaying[v] = v:Frags()
		end
	end

	for v, k in SortedPairsByValue(tblPlayersPlaying, true) do
		local colorPly1
		local colorPly2
		local vLevel
		local vXp
		local vXpNeeded

		if !v:IsBot() then
			vLevel = GLOBAL_LVLXPSTATS[v:SteamID64().."_LVL"]
			vXp = GLOBAL_LVLXPSTATS[v:SteamID64().."_XP"]
			vXpNeeded = GLOBAL_LVLXPSTATS[v:SteamID64().."_XPNEEDED"]
		end

		if v:Team() == TEAM_BLUE then
			colorPly1 = Color(0,58,117,200)
			colorPly2 = Color(0,58,117,60)
		elseif v:Team() == TEAM_RED then
			colorPly1 = Color(86,0,0,200)
			colorPly2 = Color(86,0,0,60)
		end


		local nick_lbl = vgui.Create("DButton", team_2_scroll)
		nick_lbl:SetText("")
		nick_lbl.DoClick = function()
			if !v:IsBot() then plyWantedToSee = v end
		end

		nick_lbl:SizeToContents()
		nick_lbl:SetSize(team_2_panel:GetWide(),32)
		nick_lbl:SetPos(0,num*(nick_lbl:GetTall()+4))
		nick_lbl.Paint = function()

			if v:IsValid() then
				if not v:Alive() then
					draw.RoundedBox(0,0,0,nick_lbl:GetWide(),nick_lbl:GetTall(),colorPly2)
				else
					draw.RoundedBox(0,0,0,nick_lbl:GetWide(),nick_lbl:GetTall(),colorPly1)
				end

				draw.DrawText(v:Nick(), "NexaLight20",58,5, Color(255, 255, 255, 255),TEXT_ALIGN_LEFT)
				if !v:IsBot() then
					draw.DrawText(tostring(vLevel), "NexaLight20",team_2_panel:GetWide()-240,5, Color(255, 255, 255, 255),TEXT_ALIGN_CENTER)
				end
				draw.DrawText(v:Frags(), "NexaLight20",team_2_panel:GetWide()-170,5, Color(255, 255, 255, 255),TEXT_ALIGN_CENTER)
				draw.DrawText(v:Deaths(), "NexaLight20",team_2_panel:GetWide()-100,5, Color(255, 255, 255, 255),TEXT_ALIGN_CENTER)
				draw.DrawText(v:Ping(), "NexaLight20",team_2_panel:GetWide()-30,5,Color(255, 255, 255, 255),TEXT_ALIGN_CENTER)

				if(v:GetUserGroup() == "admin") then
					surface.SetDrawColor(255,255,255,255)
					surface.SetMaterial(Material("icon16/shield.png"))
					surface.DrawTexturedRect(34,8, 16, 16)

				elseif (v:GetUserGroup() == "superadmin") then
					surface.SetDrawColor(255,255,255,255)
					surface.SetMaterial(Material("icon16/star.png"))
					surface.DrawTexturedRect(34,8, 16, 16)
				else
					surface.SetDrawColor(255,255,255,255)
					surface.SetMaterial(Material("icon16/user.png"))
					surface.DrawTexturedRect(34,8, 16, 16)
				end
			else
				draw.DrawText("DISCONNECTED", "NexaLight20",58,5, Color(255, 255, 255, 255),TEXT_ALIGN_LEFT)
			end
		end

		local avatarPly = vgui.Create( "AvatarImage", team_2_scroll )
			avatarPly:SetSize( 28, 28 )
			avatarPly:SetPos(2, num*(nick_lbl:GetTall()+4)+2)
			avatarPly:SetPlayer( v, 64 )
		num = num + 1
	end





	function Minigames:HideScoreboard()
		frame:Remove()
		Minigames.ScoreboardOpen = false
	end

end

function Minigames:TeamGamemode()
	if #team.GetPlayers(TEAM_RED) >= 1 then
		return true
	end

	return false
end
