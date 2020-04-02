Minigames = Minigames or {}
Minigames.OneInTheChamber = Minigames.OneInTheChamber or {}
Minigames.FreezeTag = Minigames.FreezeTag or {}
Minigames.GG = Minigames.GG or {}

Minigames.IsPlayingDLC = false
Minigames.DLC = true

if SERVER then
	util.AddNetworkString("MG_SendInfoString")
	util.AddNetworkString("MG_NotifyPicked")
	util.AddNetworkString("MG_NotifyFrozen")
	util.AddNetworkString("MG_NotifyGG")
	util.AddNetworkString("MG_OITC_Notify")

	hook.Add("PlayerInitialSpawn", "GetDLCInfo", function(ply)
		if Minigames.IsPlayingDLC then
			net.Start("MG_SendInfoString")
				net.WriteString(Minigames.InfoString)
			net.Send(ply)
		end
	end)
	include("mg_ff1_config.lua")
	AddCSLuaFile("mg_ff1_config.lua")
	AddCSLuaFile("sv_gungame.lua")
	AddCSLuaFile("sv_oneinthechamber.lua")
	AddCSLuaFile("sv_freezetag.lua")


	if Minigames.FastDL_DLC then
		resource.AddFile("materials/niandralades/minigames/dlc/protect.png")
	else
		resource.AddFile("684715114")
	end
else
	include("mg_ff1_config.lua")
	local protect_png =  Material("materials/niandralades/minigames/dlc/protect.png")

	net.Receive("MG_SendInfoString", function()
		Minigames.InfoString = net.ReadString()
	end)

	net.Receive("MG_OITC_Notify", function()

		local boolNetMessage = net.ReadBool()

		if boolNetMessage then
			if not LocalPlayer().NumberOfBullets then
				LocalPlayer().NumberOfBullets = 1
			end

			LocalPlayer().NumberOfBullets = LocalPlayer().NumberOfBullets + 1
		else
			LocalPlayer().NumberOfBullets = false
		end
	end)

	net.Receive("MG_NotifyFrozen", function()
		local ply = net.ReadEntity()

		if ply != LocalPlayer() then
			chat.AddText(Color(255,0,102), "[MINIGAMES] ", Color(67,191,227), ply:Nick(), Color(255,255,255), " has been been frozen!")
		else
			surface.PlaySound("physics/glass/glass_bottle_impact_hard1.wav")
		end
	end)

	net.Receive("MG_NotifyGG", function()
		--chat.AddText(Color(255,0,102), "[MINIGAMES] ", Color(255,255,255), "You got ", Color(67,191,227),  tostring(Minigames.GG.WinnerPoints) .. " Points", Color(255,255,255), " for winning Gun Game!")
	end)



	local mat = Material("materials/niandralades/minigames/bullets.png")
	hook.Add("HUDPaint", "VIP_C", function()
		if Minigames.CustomHUD then return end
		if Minigames.ScoreboardOpen then return end
		if Minigames.MapvoteOpen then return end

		local p = 100
		local o = 130
		local h = 60
		local i = 0  -- Valeur pour déterminer la valeur de la fenetre ( si i + n ==> descend la fenetre)
		local k = 2

		if Minigames:IsPlayingOITC() then
			if LocalPlayer():Alive() then
				surface.SetDrawColor(0,0,0,150)
				surface.DrawRect(ScrW()-190,ScrH()-20-20-80+20,o,h)

				surface.SetDrawColor(0,0,0)
				surface.DrawOutlinedRect(ScrW()-190  ,ScrH()-20-20-80+20,o,h)
				surface.DrawOutlinedRect(ScrW()-190-1,ScrH()-20-20-80+20-1,o + 1,h + 1)
				surface.DrawOutlinedRect(ScrW()-190-2,ScrH()-20-20-80+20-2,o + 3,h + 3)
				surface.DrawOutlinedRect(ScrW()-190-2,ScrH()-20-20-80+20-2,o + 4,h + 4)
				surface.SetDrawColor( 255, 255, 255, 255 )


				surface.SetDrawColor(Color(255,255,255,255))
				surface.SetMaterial(mat)
				surface.DrawTexturedRect(ScrW()-120, ScrH()-20-20-64+20,32,32)
				draw.DrawText(LocalPlayer().NumberOfBullets or 1, "NexaLight55", ScrW()-160, ScrH()-20-20-64, Color(255,255,255, 255),TEXT_ALIGN_LEFT)
			end
		end

		if Minigames:IsPlayingFreezeTag() then
			if LocalPlayer():IsFrozen() then
				draw.RoundedBox(0,0,0,ScrW(), ScrH(), Color(34,167,240,50))
			end
		end
	end)
end

function Minigames:IsPlayingOITC()
	if table.HasValue(Minigames.OneInTheChamber.Maps, game.GetMap()) then
		return true
	end

	return false
end

if Minigames:IsPlayingOITC() then
	include("sv_oneinthechamber.lua")
end

function Minigames:IsPlayingFreezeTag()
	if table.HasValue(Minigames.FreezeTag.Maps, game.GetMap()) then
		return true
	end

	return false
end

if Minigames:IsPlayingFreezeTag() then
	include("sv_freezetag.lua")
end

function Minigames:IsPlayingGunGame()
	if table.HasValue(Minigames.GG.Maps, game.GetMap()) then
		return true
	end

	return false
end

if Minigames:IsPlayingGunGame() then
	include("sv_gungame.lua")
end

hook.Add("InitPostEntity", "Minigames_DetectGameOnMap", function()

	if not Minigames.Gamemodes then return end

	if Minigames:IsPlayingOITC() then
		SetGlobalString("Minigames_CurrentGamemode", "OITC")
		SetGlobalInt("Minigames_RoundTime", Minigames.OneInTheChamber.RoundTime)
		Minigames.RoundLimit = Minigames.OneInTheChamber.NumberOfRounds
		Minigames.InfoString = "We're playing One In The Chamber!"
		print("DLC GAMEMODE RUNNING: " .. GetGlobalString("Minigames_CurrentGamemode"))
		Minigames.IsPlayingDLC = true
	elseif Minigames:IsPlayingFreezeTag() then
		SetGlobalString("Minigames_CurrentGamemode", "Freeze Tag")
		SetGlobalInt("Minigames_RoundTime", Minigames.FreezeTag.RoundTime)
		Minigames.RoundLimit = Minigames.FreezeTag.NumberOfRounds
		Minigames.InfoString = "We're playing Freeze Tag. Here players are given weapons and instead of \nkilling your enemy, you freeze them. If you get frozen, teammates can shoot \nyou to undo it. Freeze the entire enemy team to win the round!"
		print("DLC GAMEMODE RUNNING: " .. GetGlobalString("Minigames_CurrentGamemode"))
		Minigames.IsPlayingDLC = true
	elseif Minigames:IsPlayingGunGame() then
		SetGlobalString("Minigames_CurrentGamemode", "Gun Game")
		SetGlobalInt("Minigames_RoundTime", Minigames.GG.RoundTime)
		Minigames.RoundLimit = Minigames.GG.NumberOfRounds
		Minigames.InfoString = "We're playing Gun Game."
		print("DLC GAMEMODE RUNNING: " .. GetGlobalString("Minigames_CurrentGamemode"))
		Minigames.IsPlayingDLC = true
	end
	Minigames.Gamemodes["One In The Chamber"] = 0
	Minigames.Gamemodes["Gun Game"]  = 0
	Minigames.Gamemodes["Freeze Tag"]  = 0


	function Minigames:DefineVoteInfo(winning_key)
        /*if winning_key == "Team Deathmatch" then
            return Minigames.TeamDeathmatch.Maps*/

        if winning_key == "Free For All" then
            return Minigames.FreeForAll.Maps
        elseif winning_key =="Assault Course" then
            return Minigames.AssaultCourse.Maps
        elseif winning_key == "Two Versus All" then
            return Minigames.TwoVersusAll.Maps
        elseif winning_key == "Team Survival" then
            return Minigames.TeamSurvival.Maps
        elseif winning_key == "Capture The Flag" then
            return Minigames.CaptureTheFlag.Maps
        elseif winning_key == "One In The Chamber" then
            return Minigames.OneInTheChamber.Maps
        elseif winning_key == "Freeze Tag" then
            return Minigames.FreezeTag.Maps
        elseif winning_key == "Suicide Barrels" then
            return Minigames.SuicideBarrels.Maps
    	elseif winning_key == "Gun Game" then
            return Minigames.GG.Maps
        else
            return Minigames.AssaultCourse.Maps
        end
    end
end)
