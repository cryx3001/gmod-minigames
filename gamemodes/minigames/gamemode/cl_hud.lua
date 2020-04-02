local MG_HudPlayerInfo
local targetplayername

local HiddenHudElements = {
	CHudHealth = 1,
	CHudBattery = 1,
	CHudAmmo = 1,
	CHudSecondaryAmmo = 1,
	CHudSuitPower = 1,
	CHudPoisonDamageIndicator = 1,
	CHudCrosshair = 1,
	--CHudWeaponSelection = 1,
}

--local iconheight = 35
--local iconlength = ScrW()-995

CreateConVar("cl_showchromium","1", FCVAR_ARCHIVE)
local chromiumVarConsole = GetConVar("cl_showchromium")

function draw.Circle( x, y, radius, seg )
	local cir = {}

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = -1, seg do
		local a = math.rad( ( i / seg ) * -360 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad( 0 ) -- This is needed for non absolute segment counts
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	surface.DrawPoly( cir )
end

local function DrawCircle( ply )
	local circleOpacity

	if Minigames:IsPlayingAssaultCourse() then
		circleOpacity = 55
	elseif Minigames:IsPlayingFreeForAll() then
		circleOpacity = 0
	else
		circleOpacity = 255
	end

	if ( !IsValid( ply ) ) then return end
	if ( ply == LocalPlayer() ) then return end
	if ( !ply:Alive() ) then return end
	if( ply:Team() != LocalPlayer():Team()) then return end

	local offset = Vector( 0, 0, 1 )
	local pos = ply:GetPos() + ply:GetAimVector()*3 + offset

	cam.Start3D2D( pos, Angle( 0, 90, 0 ), 0.25 )
		surface.SetDrawColor(0, 0, 0, circleOpacity )
		draw.Circle( 2, 2, 60+10, 255 )
		surface.SetDrawColor(0, 255, 0, circleOpacity )
		--[[if ply:Team() == TEAM_BLUE then
			surface.SetDrawColor(0, 0, 255, 255 )
		elseif ply:Team() == TEAM_RED then
			surface.SetDrawColor(255, 0, 0, 255 )
		end]]
		draw.NoTexture()
		draw.Circle( 2, 2, 60, 255 )
	cam.End3D2D()
end
hook.Add( "PostPlayerDraw", "DrawCircle", DrawCircle )


hook.Add("HUDShouldDraw", "MG_Hidedefault", function(key)
	if HiddenHudElements[key] then return false end
end)

local p = 100
local o = 130
local oTwo = 180
local h = 60
local hTwo = 90

local i = 0  -- Valeur pour déterminer la valeur de la fenetre ( si i + n ==> descend la fenetre)
local k = 2
local cle = Material( "icon16/coins.png", "alphatest")
local heure = Material( "icon16/clock.png", "alphatest")

local function KeyNmbr()
	if Minigames.CustomHUD then return end
	if Minigames.ScoreboardOpen then return end
	if Minigames.MapvoteOpen then return end

	local Timestamp = os.time()
	local TimeString = os.date( "%H:%M:%S", Timestamp )

	if PS_GetPoints == nil then -- La magie obscure du Lua
		local cles = LocalPlayer():SH_GetStandardPoints()
		surface.SetDrawColor(0,0,0,150)
		surface.DrawRect(p - o/k,(i+30),o,h)



		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial(cle)
		surface.DrawTexturedRect((p - o/k) + 10,(i+65),16,16)

		surface.SetMaterial(heure)
		surface.DrawTexturedRect((p - o/k) + 10,(i+40),16,16)

		surface.SetFont("DermaLarge25")
		surface.SetFont("DermaLarge25")
		surface.SetTextColor( 255, 255, 255 )
		surface.SetTextPos((p - o/k) + 35, (i+60) )
		surface.DrawText(cles)
		surface.SetTextColor( 255, 255, 255 )
		surface.SetTextPos((p - o/k) + 35, (i+35) )
		surface.DrawText(TimeString)
	end
 end

hook.Add( "HUDPaint", "FenetreEnHautAGauche", KeyNmbr)


local height = 64+20+20
local width = 300
local size = width-40-20-64-4
local Default_HUD = Material("materials/niandralades/minigames/HUD.png")
local Red_HUD = Material("materials/niandralades/minigames/hud_red.png")
local Spec_HUD = Material("materials/niandralades/minigames/hud_else.png")

local team_string = "Unassigned"

local hud_img = Default_HUD

local ctf_flag = Material("materials/niandralades/minigames/ctf_flag.png")

surface.CreateFont( "NexaLight25", {
	font = "Nexa Light",
	size = 25,
	weight = 400,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "NexaLight35f4", {
	font = "Nexa Light",
	size = 35,
	weight = 400,
	outline = true,
} )

surface.CreateFont( "TrebuchetKillFeed", {
	font = "Trebuchet18",
	 size = 20 ,
	 weight = 900,
	} )

surface.CreateFont( "NexaTargetID", {
		font = "Nexa Light",
		 size = 25 ,
		 weight = 400,
	 } )

surface.CreateFont( "DermaLargepetit", {
	font = "DermaLarge",
	 size = 33 ,
	 outline = false,

	} )

surface.CreateFont( "DermaLarge25", {
	font = "DermaLarge",
		size = 25 ,
		outline = false,

	} )

surface.CreateFont( "DermaLargeround", {
	font = "DermaLarge",
	 size = 31 ,
	 outline = false,

	} )

surface.CreateFont( "DebugFixedSmall", {
	font = "DebugFixedSmall",
	 size = 15 ,
	 outline = false,

	} )

surface.CreateFont( "BoldSpecFont", {
	font = "DermaDefaultBold",
	 size = 28 ,
	 outline = false,

	} )


local timeLeftToBegin = 0
local curTimeWhenSend = 0

net.Receive("MG_SendTimerPreRound", function()
	timeLeftToBegin = net.ReadFloat()
	curTimeWhenSend = net.ReadFloat()
end)


function GM:HUDPaint()
	if Minigames.CustomHUD then return end
	if Minigames.ScoreboardOpen then return end
	if Minigames.MapvoteOpen then return end

	--LocalPlayer():ChatPrint(Minigames.RoundState)

	if (timeLeftToBegin + curTimeWhenSend - CurTime()) > 0  then
		--LocalPlayer():ChatPrint("OK1")
		surface.SetDrawColor(0,0,0,100)
		surface.DrawRect(ScrW()/2-220-5, ScrH()/5,450,110)
		draw.SimpleText("THE ROUND WILL BEGIN IN :","NexaLight40",ScrW()/2, ScrH()/5, Color(220,220,220,255), TEXT_ALIGN_CENTER)
		draw.SimpleText(math.Round(timeLeftToBegin + curTimeWhenSend - CurTime(),0),"NexaLight55",ScrW()/2, ScrH()/5+50, Color(240,240,240,255), TEXT_ALIGN_CENTER)
	end


	if BRANCH != "chromium" and chromiumVarConsole:GetBool() then
		draw.SimpleText("You really should use the chromium branch of GMod","NexaLight25",ScrW()/2,ScrH()-75,Color( 255, 255, 255, 255 ),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
		draw.SimpleText("to be able to see and hear many things.","NexaLight25",ScrW()/2,ScrH()-50,Color( 255, 255, 255, 255 ),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
		draw.SimpleText("Type cl_showchromium 0 in the console to hide this message.","NexaLight25",ScrW()/2,ScrH()-25,Color( 255, 255, 255, 255 ),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
	end

	local w = 280
	local h = 36

    surface.SetDrawColor(0,0,0,150)                      -- Carré des rounds
    surface.DrawRect(ScrW()/2 - w/2,30,w,h)          -- (827,30,261,36)


	local w = -165
	local h = 36

    if timer.Exists("MinigamesRoundTimer") then
		draw.SimpleText(string.ToMinutesSeconds(timer.TimeLeft("MinigamesRoundTimer")), "DermaLargepetit", ScrW()/2 - w/2,48, Color(255,255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER) else
		draw.SimpleText("00:00", "DermaLargepetit", ScrW()/2 - w/2,48, Color(255, 255, 255, 255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end

--LocalPlayer():ChatPrint(tostring(timer.Exists("RoundBeginTimer")))

local roundlimit

if Minigames:IsPlayingAssaultCourse() then
roundlimit  = Minigames.AssaultCourse.NumberOfRounds
elseif Minigames:IsPlayingFreeForAll() then
roundlimit  = Minigames.FreeForAll.NumberOfRounds
elseif Minigames:IsPlayingTeamSurvival() then
roundlimit  = Minigames.TeamSurvival.NumberOfRounds
elseif Minigames:IsPlayingTwoVersusAll() then
roundlimit  = Minigames.TwoVersusAll.NumberOfRounds
end

local w = 111
local h = 36


draw.SimpleText("Round : ".. Minigames.RoundNumber .. "/" .. Minigames.RoundLimit, "DermaLargeround", ScrW()/2 - w/2,48, Color(255, 255, 255, 255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

/*
	if Minigames:IsPlayingCaptureTheFlag() then
		if Minigames.RoundState == 1 or Minigames.RoundState == 0 then
			local pos = GetGlobalVector("CTF_BlueBase", Vector(0,0,0))
			local sceenpos = pos:ToScreen()

			surface.SetDrawColor(52, 152, 219)
			surface.SetMaterial(ctf_flag)
			surface.DrawTexturedRect(sceenpos.x, sceenpos.y-50,32,32)

			local pos = GetGlobalVector("CTF_RedBase", Vector(0,0,0))
			local sceenpos = pos:ToScreen()

			surface.SetDrawColor(242, 38, 19)
			surface.SetMaterial(ctf_flag)
			surface.DrawTexturedRect(sceenpos.x, sceenpos.y-50,32,32)

		surface.SetDrawColor(52, 152, 219)
		surface.SetMaterial(ctf_flag)
		surface.DrawTexturedRect(ScrW()/2-128-50,10,32,32)
		draw.DrawText(Minigames.BlueCaps or 0, "NexaLight55", ScrW()/2-128-35, 40, Color(255, 255, 255, 255),TEXT_ALIGN_CENTER)

		surface.SetDrawColor(242, 38, 19)
		surface.SetMaterial(ctf_flag)
		surface.DrawTexturedRect(ScrW()/2+128+20,10,32,32)
		draw.DrawText(Minigames.RedCaps or 0, "NexaLight55", ScrW()/2+128+45, 40, Color(255, 255, 255, 255),TEXT_ALIGN_CENTER)

		end
	end

*/

if not LocalPlayer():Alive() then
	if (LocalPlayer():GetObserverMode() == 5 or LocalPlayer():GetObserverMode() == 4) and LocalPlayer():GetObserverTarget():IsValid() then
		if (LocalPlayer():GetObserverTarget()):Alive() then
			MG_HudPlayerInfo = LocalPlayer():GetObserverTarget()
			targetplayername = MG_HudPlayerInfo:Name()
		end

		--draw.DrawText("You're spectating : "..targetplayername, "BoldSpecFont", 40, ScrH()/2-30, Color(255, 255, 255, 255),TEXT_ALIGN_LEFT)
	else
		return end
else
	MG_HudPlayerInfo = LocalPlayer()
end

if IsValid(MG_HudPlayerInfo) and MG_HudPlayerInfo:IsPlayer() then
	local health = MG_HudPlayerInfo:Health()
	local s = math.Round(MG_HudPlayerInfo:GetVelocity():Length())
	local s_text = math.Round(MG_HudPlayerInfo:GetVelocity():Length())

	if MG_HudPlayerInfo:Team() == TEAM_BLUE then
		team_string    = "Blue Team"
		surface.SetDrawColor(0, 0, 255, 255 )
		w = width-190
	elseif MG_HudPlayerInfo:Team() == TEAM_RED then
		team_string    = "Red Team"
		surface.SetDrawColor(255, 0, 0, 255 )
		w = width-190
	elseif MG_HudPlayerInfo:Team() == TEAM_SPECTATOR then
		team_string    = "Spectator"
		surface.SetDrawColor(150, 150, 150, 255 )
		w = width-190
	elseif MG_HudPlayerInfo:Team() == TEAM_GHOST then
		team_string    = "Ghost"
		surface.SetDrawColor(150, 150, 150, 255 )
		w = width-180
	else
		team_string    = "Warmup"
		surface.SetDrawColor(150, 150, 150, 255 )
		w = width-180
	end


	draw.NoTexture()

	draw.Circle( p - o/k + 20, ScrH()-5-20-64, 10, 200)

	surface.SetDrawColor(0,0,0,150)
	surface.DrawRect(p-o/k,ScrH()-20-20-80-30+20+22,width-124,hTwo-20)


	//draw.RoundedBox(0, p - o/k, ScrH()-20-20-64, w,30,Color(29, 33, 38, 150))

	//draw.RoundedBox(0, p - o/k+1, ScrH()-5-64,width-124.5,30,Color(29, 33, 38))
	draw.RoundedBoxEx(0, p - o/k+2+1, ScrH()-5-60-2,math.Clamp(health*2-10,1,size)-1,13,Color(220, 40, 57),true,true,false,false)
	draw.RoundedBoxEx(0, p - o/k+2+1, ScrH()-5-60+11,math.Clamp(health*2-10,1,size)-1,13,Color(204, 26, 46),false,false,true,true)

	draw.DrawText(team_string, "Roboto15", p - o/k +20+20, ScrH()-12-20-64, Color(255, 255, 255, 255),TEXT_ALIGN_LEFT)
	draw.DrawText(health, "Roboto15", p - o/k + 90,ScrH()-5-26-30, Color(255, 255, 255, 255),TEXT_ALIGN_CENTER)
end

	if CanBuy then
		draw.DrawText("You can buy weapons here!", "NexaLight35f4", ScrW()/2, ScrH()/2*1.2, Color(255, 255, 255, 255),TEXT_ALIGN_CENTER)
		draw.DrawText("Press "..string.upper(input.LookupBinding("gm_showspare2")).."!", "NexaLight35f4", ScrW()/2, ScrH()/2*1.2+28,Color(255, 255, 255, 255),TEXT_ALIGN_CENTER)
	end


	GAMEMODE:HUDDrawTargetID()
end

/*
net.Receive("Minigames_AvatarHUD", function()
	local toggle = net.ReadBool()
	Minigames:ToggleAvatar(toggle)
end)

local a_tbl = {}
function Minigames:ToggleAvatar(toggle)
	if toggle then
		if Minigames.MapvoteOpen then return end

		local frame = vgui.Create("DFrame")
		frame:SetSize(68,68)
		frame:ShowCloseButton(false)
		frame:SetTitle("")
		frame:SetPos(20+20, ScrH()-20-20-64)
		frame.Paint = function()
			draw.RoundedBox(0, 0, 0,frame:GetWide(),frame:GetTall(),Color(29, 33, 38))
		end

		table.insert(a_tbl, frame)

		local avatar = vgui.Create("AvatarImage", frame)
		avatar:SetPos(2,2)
		avatar:SetSize(64,64)
		avatar:SetPlayer(LocalPlayer(), 64)
	else

		Minigames:RemoveAvatarHUD()
	end
end

function Minigames:RemoveAvatarHUD()
	if #a_tbl < 1 then return end
	for k, v in pairs(a_tbl) do
		v:Remove()
	end
end
*/

local weps = {
["weapon_ak47"] = "b",
["weapon_aug"] = "e",
["weapon_awp"] = "r",
["weapon_csfrag"] = "O",
["weapon_deagle"] = "f",
["weapon_elite"] = "s",
["weapon_famas"] = "t",
["weapon_fiveseven"] = "u",
["weapon_g3sg1"] = "i",
["weapon_galil"] = "v",
["weapon_glock"] = "c",
["weapon_knife"] = "j",
["weapon_m3"] = "k",
["weapon_m4a1"] = "w",
["weapon_m249"] = "z",
["weapon_mac10"] = "l",
["weapon_mp5"] = "x",
["weapon_p90"] = "m",
["weapon_p228"] = "a",
["weapon_scout"] = "n",
["weapon_sg550"] = "o",
["weapon_sg552"] = "A",
["weapon_smoke"] = "",
["weapon_tmp"] = "d",
["weapon_ump45"] = "q",
["weapon_usp"] = "y",
["weapon_xm1014"] = "B",
}

surface.CreateFont( "weaponicon", {
	font = "csd",
	 size = 60 ,
	 outline = false,

	} )


net.Receive("MG_Killfeed", function()
	Minigames:KillFeed(net.ReadEntity(),net.ReadEntity())
end)

local wepinconw = 60
Minigames.KillFeedNum = 0

local tbl_freeslots = {}
function Minigames:KillFeed(killer,victim)
	local killernicksize
	local rankToGet = 0

	print(Minigames.KillFeedNum)
	if tbl_freeslots[Minigames.KillFeedNum] == nil then
		table.insert(tbl_freeslots, Minigames.KillFeedNum, false)
	else
		for k, v in pairs(tbl_freeslots) do
			if v == true then
				rankToGet = k
				break
			end
		end
	end
	--PrintTable(tbl_freeslots)

	if tbl_freeslots[Minigames.KillFeedNum+1] == nil then
		table.insert(tbl_freeslots, (Minigames.KillFeedNum + 1), true)
	end

	if killer:IsWorld() then
		print(victim:GetName() .. " died by the world")

	elseif killer:IsPlayer() then
	  if not killer:GetActiveWeapon():IsValid() then
			print(victim:GetName() .. " died to a unknown weapon")
			getwepletter = "C"
		else
			print(killer:GetName() .. " killed " .. victim:GetName() .. " with " .. killer:GetActiveWeapon():GetClass())
			local killerweapon = tostring(killer:GetActiveWeapon():GetClass())
			getwepletter = weps[killerweapon]
		end

		if getwepletter == nil then
			getwepletter = "C"
		end

		if killer == victim then
			getwepletter = "C"
		end

	else
		print(victim:GetName() .. " died to a unknown force")
		getwepletter = "C"
	end

	local frame = vgui.Create("DPanel")
	frame:SetSize(800,40)
	frame:SetPos(ScrW()+frame:GetWide(),5+rankToGet*frame:GetTall()+50)
	frame.Paint = function()
		draw.RoundedBox(0,0,0,frame:GetWide(),frame:GetTall(),Color(35, 35, 35, 0))
	end

  	if killer:IsPlayer() then
		killernicksize = ((string.len(killer:GetName()))*9)+10

		if (string.len(killer:GetName())) > 15 then
			killernicksize = (15*9)+10
		end
	else
		killernicksize = 0
	end

	local victimnicksize = ((string.len(victim:GetName()))*9)+10

	if (string.len(victim:GetName())) > 15 then
		victimnicksize = (15*9)+10
	end

	local killfeedlayout = vgui.Create("DIconLayout" , frame)
	killfeedlayout:Dock( FILL )
	killfeedlayout:SetSpaceY( 0 )
	killfeedlayout:SetSpaceX( 5 )

	local KillerAvatar = killfeedlayout:Add("AvatarImage")
	KillerAvatar:SetSize( 32, 32 )

	local KillerNick = killfeedlayout:Add("DLabel")
	KillerNick:SetFont("TrebuchetKillFeed")
--	KillerNick:SetColor( team.GetColor(killer:Team()) )

	local WeaponIcono = killfeedlayout:Add("DLabel")
	local VictimAvatar = killfeedlayout:Add("AvatarImage")
	local VictimNick = killfeedlayout:Add("DLabel")
	VictimNick:SetFont("TrebuchetKillFeed")
--	VictimNick:SetColor( team.GetColor(victim:Team()))
	VictimAvatar:SetSize( 32, 32 )
	WeaponIcono:SetFont("weaponicon")
	WeaponIcono:SetSize(10,10)


	if killer:IsWorld() then
		WeaponIcono:SetText("C")
		WeaponIcono:SetSize(100,60)
		KillerAvatar:SetPlayer(victim, 32)
		KillerNick:SetText(victim:GetName())
		KillerNick:SetSize( victimnicksize, 35 )
		KillerNick:SetColor( team.GetColor(victim:Team()) )
		frame:SetSize(32+victimnicksize+100+15,40)
		VictimAvatar:Remove()
		VictimNick:Remove()

	elseif killer:IsPlayer() then
		if not killer:GetActiveWeapon():IsValid() then
			WeaponIcono:SetSize(100,60)
			WeaponIcono:SetText("C")
			KillerAvatar:SetPlayer(killer, 32)
			KillerNick:SetText(killer:GetName())
			KillerNick:SetSize( killernicksize, 35 )
			KillerNick:SetColor( team.GetColor(killer:Team()) )
			VictimAvatar:SetPlayer(victim, 32)
			VictimNick:SetText(victim:GetName())
			VictimNick:SetSize( victimnicksize, 35 )
			VictimNick:SetColor( team.GetColor(victim:Team()))
			frame:SetSize(32*2+victimnicksize+killernicksize+100+25,40)

		else
			WeaponIcono:SetSize(100,60)
			WeaponIcono:SetText(getwepletter)
			KillerAvatar:SetPlayer(killer, 32)
			KillerNick:SetText(killer:GetName())
			KillerNick:SetSize( killernicksize, 35 )
			KillerNick:SetColor( team.GetColor(killer:Team()) )
			VictimAvatar:SetPlayer(victim, 32)
			VictimNick:SetText(victim:GetName())
			VictimNick:SetSize( victimnicksize, 35 )
			VictimNick:SetColor( team.GetColor(victim:Team()))
			frame:SetSize(32*2+victimnicksize+killernicksize+100+25,40)
	  end

	else
		WeaponIcono:SetSize(100,60)
		WeaponIcono:SetText("C")
		KillerAvatar:SetPlayer(victim, 32)
		KillerNick:SetText(victim:GetName())
		KillerNick:SetSize( victimnicksize, 35 )
		KillerNick:SetColor( team.GetColor(victim:Team()) )
  		frame:SetSize(32+victimnicksize+100+15,40)
		VictimAvatar:Remove()
		VictimNick:Remove()
	end

	tbl_freeslots[rankToGet] = false

	frame:MoveTo(ScrW()-frame:GetWide(),frame.y-25,0.1,0,1, function()
		frame:MoveTo(ScrW()+frame:GetWide(),frame.y-25,0.1,3,1, function()
			frame:Remove()
			Minigames.KillFeedNum = Minigames.KillFeedNum - 1

			for k, v in pairs(tbl_freeslots) do
				if v == false then
					tbl_freeslots[k] = true
					break
				end
			end

			--print("----- after timer")
			--PrintTable(tbl_freeslots)
		end)
	 end)

	Minigames.KillFeedNum = Minigames.KillFeedNum + 1
end

--Custom Target ID

hook.Add("RenderScreenspaceEffects","RoundStateVisual",function()
	if (timeLeftToBegin + curTimeWhenSend - CurTime()) > 0 then
		--LocalPlayer():ChatPrint("OK2")
		local tab = {
			[ "$pp_colour_brightness" ] = 0,
			[ "$pp_colour_contrast" ] = 1,
			[ "$pp_colour_colour" ] = 0,
		}
		DrawColorModify( tab )
	else
		local tab = {
		[ "$pp_colour_brightness" ] = 0,
		[ "$pp_colour_contrast" ] = 1,
		[ "$pp_colour_colour" ] = 1,
	}
		DrawColorModify( tab )
	end
end)

/*
local roundInfo
net.Receive("Minigames_NotifyRound",function()
	local roundState = net.ReadString()
	local teamWon = net.ReadString()
	local playerWon = net.ReadString()

	local entToShow
	if playerWon then entToShow = playerWon else entToShow = teamWon end

	timer.Simple(0.2,function()
		if roundInfo then roundInfo:Remove() end

		timer.Simple(5,function() roundInfo:Remove() end)
	end)
end)
*/
local specInfo
net.Receive("Minigames_SendSpecEntity", function()
	if timer.Exists("checkPlyForSpec") then timer.Remove("checkPlyForSpec") end

	timer.Simple(0.2, function()
		if specInfo then specInfo:Remove() end

		if (LocalPlayer():GetObserverMode() == 4 or LocalPlayer():GetObserverMode() == 5) and LocalPlayer():GetObserverTarget():IsValid() then
			local plySpec = LocalPlayer():GetObserverTarget()
			local plySpecName = plySpec:Nick()

			specInfo = vgui.Create("DFrame")
				specInfo:SetTitle("")
				specInfo:ShowCloseButton(false)
				specInfo:IsDraggable(false)
				specInfo:SetPos(30, ScrH()/3)
				specInfo:SetSize(256,86)

				specInfo.Paint = function()
					draw.RoundedBox(0, 0, 0,specInfo:GetWide(),specInfo:GetTall(),Color(0, 0, 0, 100))
					draw.DrawText(plySpecName, "NexaLight30", 70+8+4, 5, Color(255,255,255,255), TEXT_ALIGN_LEFT)
					if !plySpec:IsBot() then
						draw.DrawText("Lvl "..GLOBAL_LVLXPSTATS[plySpec:SteamID64().."_LVL"], "NexaLight30", 70+8+4, 35, Color(255,255,255,255), TEXT_ALIGN_LEFT)
					end

				end

			local avatar = vgui.Create("AvatarImage", specInfo)
				avatar:SetPos(8,8)
				avatar:SetSize(70,70)
				avatar:SetPlayer(plySpec, 64)



			--print(plySpecName.." OK")
			--print(specInfo)
		else
			--print(plySpecName.." NOK")
		end
	end)

	timer.Create("checkPlyForSpec",0,0.2,function()
		if (LocalPlayer():Alive() or !LocalPlayer():GetObserverTarget():IsValid() or !LocalPlayer():GetObserverTarget() or (LocalPlayer():GetObserverMode() != 4 and LocalPlayer():GetObserverMode() != 5) or LocalPlayer():GetObserverTarget() == LocalPlayer()) and specInfo then
			specInfo:Remove()
		end
	end)
end)
