include("shared.lua")
include("config_maps.lua")
include("ply_extension.lua")
include("cl_networkstrings.lua")
include("cl_fonts.lua")
include("cl_hud.lua")
include("cl_mapvote.lua")
include("cl_buymenu.lua")
include("config_mapvote.lua")
include("config_general.lua")


Minigames.SBT = Minigames.SBT or {}

function AddScoreboardButton(num,options)
	Minigames.SBT[num] = {
		ButtonName = options.ButtonName,
		Icon = options.Icon,
		Function = options.Function
	}
end

-- I know using a table instead of a bool is weird, but the other wasnt working correctly :(
local f2open = {}
function Minigames:SelectTeams()

	if #f2open >= 1 then
		 Minigames:CloseTeamMenu()
		 return
	end

	if Minigames.ScoreboardOpen then
		Minigames:HideScoreboard()
	end

	local frame = vgui.Create("DFrame")
	frame:SetSize(310, 420)
	frame:SetTitle("")
	frame:ShowCloseButton(false)
	frame:Center()
	frame:ShowCloseButton(false)
	frame.Paint = function()
		draw.RoundedBox(0,0,0,frame:GetWide(),50,Color(0,0,0,100))
		draw.DrawText("Choose a Team", "NexaLight35",frame:GetWide()/2,5, Color(255, 255, 255, 255),TEXT_ALIGN_CENTER)
	end
	frame.Think = function()
		gui.EnableScreenClicker(true)
	end


	table.insert(f2open,frame)

	local team_players = vgui.Create("DButton", frame)
	team_players:SetSize(150, 300)
	team_players:SetPos(0,60)
	team_players:SetText("")
	team_players.DoClick = function()
		if LocalPlayer():Team() ~= TEAM_BLUE and LocalPlayer():Team() ~= TEAM_RED  then
			if Minigames:CanJoinBlue() or Minigames:CanJoinRed() then
				net.Start("Team_Select_Serverside")
					net.WriteString("player")
				net.SendToServer()

				chat.AddText(Color(255,60,60), "[MINIGAMES] ", Color(255,255,255), "You have joined ", Color(75,0,100), "the players ", Color(255,255,255),"!")
				Minigames:CloseTeamMenu()
			else
				chat.AddText(Color(255,60,60), "[MINIGAMES] ", Color(255,255,255), "Sorry, this team is ", Color(98,177,255), "full ", Color(255,255,255),"!")
			end
		else
			chat.AddText(Color(255,60,60), "[MINIGAMES] ", Color(255,255,255), "You're already playing !")
			Minigames:CloseTeamMenu()
		end
	end
	team_players.Paint = function()
		draw.RoundedBox(0,0,0,team_players:GetWide(),team_players:GetTall(),Color(75,0,100,150))
		draw.DrawText("Play!", "NexaLight35",team_players:GetWide()/2,5, Color(255, 255, 255, 255),TEXT_ALIGN_CENTER)
		draw.DrawText("Players", "NexaLight25",team_players:GetWide()/2,team_players:GetTall()-60, Color(255, 255, 255, 255),TEXT_ALIGN_CENTER)
		draw.DrawText((#team.GetPlayers(2) + #team.GetPlayers(3)), "NexaLight120",team_players:GetWide()/2,team_players:GetTall()/2-60, Color(255, 255, 255, 255),TEXT_ALIGN_CENTER)
	end


	local spectator = vgui.Create("DButton", frame)
	spectator:SetSize(150, 300)
	spectator:SetPos(160,60)
	spectator:SetText("")
	spectator.DoClick = function()
		if LocalPlayer():Team() ~= TEAM_SPECTATOR then
			net.Start("Team_Select_Serverside")
				net.WriteString("spec")
			net.SendToServer()
			chat.AddText(Color(255,60,60), "[MINIGAMES] ", Color(255,255,255), "You have joined the ", Color(150,150,150), "spectators ", Color(255,255,255),"!")
			Minigames:CloseTeamMenu()
		else
			 Minigames:CloseTeamMenu()
		end
	end
	spectator.Paint = function()
		draw.RoundedBox(0,0,0,spectator:GetWide(),spectator:GetTall(),Color(150,150,150,150))
		draw.DrawText("Look !", "NexaLight35",spectator:GetWide()/2,5, Color(255, 255, 255, 255),TEXT_ALIGN_CENTER)
		draw.DrawText("Spectators", "NexaLight25",spectator:GetWide()/2,spectator:GetTall()-60, Color(255, 255, 255, 255),TEXT_ALIGN_CENTER)
		draw.DrawText(#team.GetPlayers(TEAM_SPECTATOR), "NexaLight120",team_players:GetWide()/2,team_players:GetTall()/2-60, Color(255, 255, 255, 255),TEXT_ALIGN_CENTER)

	end

	/*
	local spectator = vgui.Create("DButton", frame)
	spectator:SetSize(frame:GetWide(), 50)
	spectator:SetPos(0,frame:GetTall()-50)
	spectator:SetText("")
	spectator.DoClick = function()
		if LocalPlayer():Team() ~= TEAM_SPECTATOR then
			net.Start("Team_Select_Serverside")
				net.WriteString("spec")
			net.SendToServer()
			chat.AddText(Color(255,60,60), "[MINIGAMES] ", Color(255,255,255), "You have joined the ", Color(98,177,255), "spectators ", Color(255,255,255),"!")
			Minigames:CloseTeamMenu()
		else
			 Minigames:CloseTeamMenu()
		end
	end
	spectator.Paint = function()
		draw.RoundedBox(0,0,0,spectator:GetWide(),spectator:GetTall(),Color(0,0,0,100))
		draw.DrawText("Spectators", "NexaLight35",spectator:GetWide()/2,7, Color(255, 255, 255, 255),TEXT_ALIGN_CENTER)
	end
	*/

	function Minigames:CloseTeamMenu()
		for k, v in pairs(f2open) do
			v:Remove()
		end
		f2open = {}
		gui.EnableScreenClicker(false)
	end
end

Minigames.InfoString = Minigames.InfoString or "If you see this message, then the map isn't on a particular gamemode, please report this"
/*
if Minigames:IsPlayingTeamDeathmatch() then
	Minigames.InfoString = "We're playing Team Deathmatch. éliminate the opposing team \n Each round, every players are given a random loadout."
*/
if Minigames:IsPlayingTeamSurvival() then
	Minigames.InfoString = "We're playing Team Survival. \nPlayers are separated into 2 teams, blue and red. \nComplete the objectives of the map to win"
elseif Minigames:IsPlayingFreeForAll() then
	Minigames.InfoString = "We're playing Free For All. \nLast player alive wins the round"
elseif  Minigames:IsPlayingAssaultCourse() then
	Minigames.InfoString = "We're playing Assault Course. \nYou're competing against other players to get at the end of the map \nWatchout for traps!!! \nPress Use on teddy to finish"
elseif Minigames:IsPlayingTwoVersusAll() then
	Minigames.InfoString = "We're playing Two Versus All. Each Round, two players are chosen to be in the red team \nTheir goals is to eliminate the other players, and you to survive. \nLast team alive wins!"
/*
elseif Minigames:IsPlayingCaptureTheFlag() then
	Minigames.InfoString = "We're playing Capture The Flag. \nEach team have a flag at their spawn. \nprotect your team flag or capture the enemy flag \na leur propre drapeau. Les tuer leur fait tomber votre drapeau et " .. Minigames.CaptureTheFlag.FlagReset .. " en quelque secondes \nreviendra à votre base."
*/
end


local pressed_keyFOne
local F1menu

hook.Add("Think", "F1ToOpenHelpMenu_hud", function()
    if input.IsKeyDown(KEY_F1) and not pressed_keyFOne then
		pressed_keyFOne = true

		if F1menu == nil or not F1menu:IsValid() then
			OpenFOneHelpMenu()
		else
			F1menu:Close()
		end

	elseif pressed_keyFOne and not input.IsKeyDown(KEY_F1) then
		pressed_keyFOne = false
	end
end)

function OpenFOneHelpMenu()

	surface.CreateFont( "Dermacredits", {
		font = "DermaLarge",
		 size = 18 ,
		 outline = false,
		} )

	local widthf1 = 800  --Scaling stuff
	local heightf1 = 700
	local wawa = Color(0,0,0,150)  --Transparent black

	F1menu = vgui.Create( "DFrame" )
	F1menu:SetSize( widthf1, heightf1)
	F1menu:SetTitle( "Menu" )
	F1menu:MakePopup()                                  -- Main window
	F1menu:Center()
	F1menu:SetDraggable(false)
	F1menu.Paint = function(self, w, h)
	  draw.RoundedBox(0,0,0,w,h,Color(0,0,0,150))
	end



	local onglets = vgui.Create( "DPropertySheet", F1menu )
	onglets:Dock( FILL )
	onglets.Paint = function(self, w, h)                             --Need to check in someway change the color of a tab on this
	  draw.RoundedBox(0,0,0,w,h,Color(0,0,0,150))
	end

	local tutorial = vgui.Create( "DPanel", onglets )
	onglets:AddSheet( "Tutorial", tutorial, "icon16/asterisk_yellow.png" )
	tutorial:SetBackgroundColor(wawa)
	tutorial.Paint = function(self, w, h)
	  draw.RoundedBox(0,0,0,w,h,Color(0,0,0,150))
	end

	local htmltutorial = vgui.Create( "DHTML", tutorial )
	htmltutorial:Dock( FILL )
	htmltutorial:OpenURL( "http://cryx3001.github.io/minigames/tutorialtextmg.html" )

	local rules = vgui.Create( "DPanel", onglets )
	onglets:AddSheet( "Rules", rules, "icon16/user_suit.png" )
	rules.Paint = function(self, w, h)
	  draw.RoundedBox(0,0,0,w,h,Color(0,0,0,150))
	end

	local htmlrules = vgui.Create( "DHTML", rules )
	htmlrules:Dock( FILL )
	htmlrules:OpenURL( "http://cryx3001.github.io/minigames/rulesmg.html" )

/*
	local credits = vgui.Create( "DPanel", onglets )
	onglets:AddSheet( "Credits", credits, "icon16/report.png" )
	credits.Paint = function(self, w, h)
	  draw.RoundedBox(0,0,0,w,h,Color(0,0,0,150))
	end

	local minigamesheadproject = vgui.Create("DLabel", credits)
	minigamesheadproject:SetText("Minigames Super Admins")
	minigamesheadproject:SetPos(widthf1/4,-75)
	minigamesheadproject:SetFont("DermaLarge")                     --Text for title of the 3 minigames superadmins
	minigamesheadproject:SetSize(700,200)
	minigamesheadproject:SetColor(Color(255,45,45))

	local icezposw = (widthf1/1.4)
	local cryxposw = (widthf1/2.60)  --Scaling stuff
	local creditsposh = 50

	local raykeno = vgui.Create("DLabel", credits)
	raykeno:SetText("Raykeno\nDesign, Pointshop and stuff")
	raykeno:SetPos(20,creditsposh)
	raykeno:SetFont("Dermacredits")
	raykeno:SetSize(700,200)
	local cryx = vgui.Create("DLabel", credits)
	cryx:SetText("Cryx\nCoding and some stuff")                         --Credits minigames superadmin text
	cryx:SetPos(cryxposw,creditsposh)
	cryx:SetFont("Dermacredits")
	cryx:SetSize(700,200)
	local icez = vgui.Create("DLabel", credits)
	icez:SetText("Icez\nHead of Project?")
	icez:SetPos(icezposw,creditsposh)
	icez:SetFont("Dermacredits")
	icez:SetSize(700,200)

	local raykenoavatar = vgui.Create( "AvatarImage" , credits )
	raykenoavatar:SetSize( 64, 64 )
	raykenoavatar:SetPos( 20+50, creditsposh+10 )
	raykenoavatar:SetSteamID("76561198039317868",64)

	local raykenobutton = vgui.Create("DButton",credits)
	raykenobutton:SetSize( 64, 64 )
	raykenobutton:SetPos( 20+50, creditsposh+10 )
	raykenobutton:SetText("")
	raykenobutton.Paint = function() end
	raykenobutton.DoClick = function()
		gui.OpenURL( "https://steamcommunity.com/profiles/76561198039317868/" )
	end


	local cryxavatar = vgui.Create( "AvatarImage" , credits )
	cryxavatar:SetSize( 64, 64 )
	cryxavatar:SetPos( cryxposw+40, creditsposh+10 )
	cryxavatar:SetSteamID("76561198000684674",64)

	local cryxbutton = vgui.Create("DButton",credits)
	cryxbutton:SetSize( 64, 64 )
	cryxbutton:SetPos( cryxposw+40, creditsposh+10 )
	cryxbutton:SetText("")
	cryxbutton.Paint = function() end
	cryxbutton.DoClick = function()
		gui.OpenURL( "https://steamcommunity.com/profiles/76561198000684674/" )
	end


	local icezavatar = vgui.Create( "AvatarImage" , credits )
	icezavatar:SetSize( 64, 64 )
	icezavatar:SetPos( icezposw+20, creditsposh+10 )
	icezavatar:SetSteamID("76561198118644723",64)

	local icezbutton = vgui.Create("DButton",credits)
	icezbutton:SetSize( 64, 64 )
	icezbutton:SetPos( icezposw+20, creditsposh+10 )
	icezbutton:SetText("")
	icezbutton.Paint = function() end
	icezbutton.DoClick = function()
		gui.OpenURL( "https://steamcommunity.com/profiles/76561198118644723/" )
	end
*/

	if BRANCH != "chromium" then
		local chromiumAdviceFrame = vgui.Create("DPanel",F1menu)
		chromiumAdviceFrame:SetSize(F1menu:GetWide(), F1menu:GetTall()-300)
		chromiumAdviceFrame:SetPos(0,150)
		chromiumAdviceFrame.Paint = function()
			draw.DrawText("Chromium branch of GMod is needed to see this.","NexaLight25", chromiumAdviceFrame:GetWide()/2, chromiumAdviceFrame:GetTall()/2,Color( 255, 255, 255, 255 ),TEXT_ALIGN_CENTER)
		end
	end
end

-- Disable default looking at target and get info
function GM:HUDDrawTargetID()
	if LocalPlayer():Alive() == false then return end
	local tr = util.GetPlayerTrace( LocalPlayer() )
	local trace = util.TraceLine( tr )
	if ( !trace.Hit ) then return end
	if ( !trace.HitNonWorld ) then return end

	local text = "ERROR"
	local font = "NexaTargetID"
	if ( trace.Entity:IsPlayer() ) then
		text = trace.Entity:Nick()
	else
		return
	end

	surface.SetFont( font )
	local w, h = surface.GetTextSize( text )
	local MouseX, MouseY = gui.MousePos()

	if ( MouseX == 0 && MouseY == 0 ) then

		MouseX = ScrW() / 2
		MouseY = ScrH() / 2

	end

	local x = MouseX
	local y = MouseY

	x = x - w / 2
	y = y + 30

	draw.SimpleText( text, font, x, y, team.GetColor( trace.Entity:Team() ) )

	y = y + h + 5

	local text = trace.Entity:Health()
	local font = "NexaTargetID"
	local health = trace.Entity:Health()
	if health >= 100 then health = 100 end
	local icongaugeheight = math.ceil(health/6.25)


	surface.SetFont( font )
	local w, h = surface.GetTextSize( text )
	local x = MouseX - w / 2

	local hearticon = Material("icon16/heart.png")
	surface.SetMaterial(hearticon)
	surface.SetDrawColor(0,0,0,255)
	surface.DrawTexturedRect(x+w+5,y+5,16,16)
	surface.SetDrawColor(255,0,0,255)
	surface.DrawTexturedRectUV(x+w+5,y+5,16,icongaugeheight,0,0,1,health/100)

	draw.SimpleText( text, font, x, y, team.GetColor( trace.Entity:Team() ))

end

function Minigames:PlayerModel()

	local selected = LocalPlayer():GetModel()

	local frame = vgui.Create("DFrame")
	frame:SetSize(600,500)
	frame:SetTitle("Select a Player Model")
	frame:Center()
	frame.OnClose = function()
		gui.EnableScreenClicker(false)
	end
	frame.Paint = function()
		draw.RoundedBox(0,0,0,frame:GetWide(),frame:GetTall(),Color(26,26,26))
	end
	frame.Think = function()
		gui.EnableScreenClicker(true)
	end

	local background = vgui.Create("DScrollPanel", frame)
	background:SetSize(frame:GetWide()-50,frame:GetTall()-75)
	background:SetPos(25,50)
	background.Paint = function()
	end


	local num = 0
	for k, v in pairs(Minigames.GenericPlayerModels) do
		local pm_panels = vgui.Create("DButton", background)
		pm_panels:SetText(v)
		pm_panels:SetColor(Color(255,255,255))
		pm_panels:SetFont("Bebas40")
		pm_panels:SetSize(550, 64)
		pm_panels:SetPos(0, 0+num*65)
		pm_panels.Paint = function()
			if v != selected then
				draw.RoundedBox(0,0,0,pm_panels:GetWide(),pm_panels:GetTall(),Color(49,49,49))
			else
				draw.RoundedBox(0,0,0,pm_panels:GetWide(),pm_panels:GetTall(),Color(242,99,91))
			end
		end
		pm_panels.DoClick = function()
			net.Start("Minigames_ChoosePlayerModel")
				net.WriteString(v)
			net.SendToServer()
			selected = v
			chat.AddText(Color(242,99,91), "[MINIGAMES] ", Color(255,255,255), "You have changed your default playermodel!")
		end

		local v_model = vgui.Create("SpawnIcon", pm_panels)
		v_model:SetModel(v)
		v_model:SetSize(64,64)
		v_model:SetPos(0,0)

		num = num + 1
	end
end

net.Receive("MG_ShowPanelPlayerModel", function()
	Minigames:PlayerModel()
end)
function Minigames:RequestRTVFromClient()
	net.Start("MG_RequestRTVFromClient")
	net.SendToServer()
end

include("cl_scoreboard.lua")

--[[
CreateClientConVar("autojump", 0, true, false)

function Bunnyhop()
	if GetConVar("autojump"):GetInt() == 1 then
		if input.IsKeyDown(KEY_SPACE) then
			if LocalPlayer():IsOnGround() and LocalPlayer():Alive() then
				RunConsoleCommand("+jump")
				timer.Create("Bhop", 0, 0.01, function()
				RunConsoleCommand("-jump")

				end)
			end
		end
	end
end
hook.Add("Think", "Hoppy", Bunnyhop )
--]]

hook.Add( "ChatText", "hide_joinleave", function( index, name, text, typ )
	if ( typ == "joinleave" ) then return true end
end )
