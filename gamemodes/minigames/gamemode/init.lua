--AddCSLuaFile
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("ply_extension.lua")
AddCSLuaFile("config_general.lua")
AddCSLuaFile("config_maps.lua")
AddCSLuaFile("cl_networkstrings.lua")
AddCSLuaFile("cl_fonts.lua")
AddCSLuaFile("cl_hud.lua")
AddCSLuaFile("cl_fonts.lua")
AddCSLuaFile("cl_buymenu.lua")
AddCSLuaFile("cl_mapvote.lua")
AddCSLuaFile("cl_scoreboard.lua")
AddCSLuaFile("config_mapvote.lua")

--Include
include("shared.lua")
include("sv_chatcommands.lua")
include("config_maps.lua")
include("config_general.lua" )
include("sv_rounds.lua")
include("buymenu.lua")
include("ply_extension.lua")
include("config_mapvote.lua")
include("sv_mapvote.lua")
include("sv_mvp_ply.lua")

--Network Strings
util.AddNetworkString("Minigames_SendSpecEntity")
util.AddNetworkString("Minigames_PlyDisconnected")
util.AddNetworkString("Minigames_PlyConnected")
util.AddNetworkString("Minigames_NotifyRound")
util.AddNetworkString("Minigames_PointsOnKill")
util.AddNetworkString("Minigames_ChoosePlayerModel")
util.AddNetworkString("Minigames_WriteTeddy")
util.AddNetworkString("Minigames_AvatarHUD")
util.AddNetworkString("Minigames_MapVote")
util.AddNetworkString("Minigames_MapVote_CtS")
util.AddNetworkString("Minigames_MapVote_SbtC")
util.AddNetworkString("Minigames_MapChoice")
util.AddNetworkString("Minigames_SendMap")
util.AddNetworkString("Minigames_SendVotesPerMap")
util.AddNetworkString("Minigames_SendWinningMap")
util.AddNetworkString("Minigames_NotifyRTV")
util.AddNetworkString("MG_SendTimerPreRound")
util.AddNetworkString("MG_VOTENotif")
util.AddNetworkString("Team_Select")
util.AddNetworkString("Team_Select_Serverside")
util.AddNetworkString("F_Help")
util.AddNetworkString("F_Teams")
util.AddNetworkString("MG_DisplayWinner")
util.AddNetworkString("MG_RequestRTVFromClient")
util.AddNetworkString("MG_NotifyTeamBalance")
util.AddNetworkString("MG_NotifyScramble")
util.AddNetworkString("CTF_FlagToggle")
util.AddNetworkString("CTF_Reset")
util.AddNetworkString("CTF_Capt")
util.AddNetworkString("CTF_SendCaptures")
util.AddNetworkString("CTF_AddCapture")
util.AddNetworkString("MG_SendInitalData")
util.AddNetworkString("MG_Killfeed")
util.AddNetworkString("TVA_AutoBalance")
util.AddNetworkString("MG_ShowPanelPlayerModel")

resource.OldAddFile("materials/sprites/scope.vtf")
resource.OldAddFile("materials/sprites/scope.vmt")
resource.AddSingleFile("materials/sprites/scope.vtf")
resource.AddSingleFile("materials/sprites/scope.vmt")
resource.AddSingleFile("html/tutorialtextmg.html")
resource.AddSingleFile("html/rulesmg.html")

local misc = file.Find("materials/niandralades/minigames/*.png", "MOD" )
local icons = file.Find("materials/niandralades/minigames/mapicons/*.png", "MOD" )

function initialize_sql_maps()
    if !sql.TableExists("maps_locked") then
        local query = "CREATE TABLE maps_locked ( id int, map string)"
        local result = sql.Query(query)
        print("BASE DE DONNEES SQL CREE")
    else
        print("BASE DE DONNEES SQL EXISTANTE")
    end
    print("PREPARATION BASE SQL")
end
initialize_sql_maps()

if Minigames.EnableFastDL then

	resource.AddFile("resource/fonts/Nexa Light.otf")

	--this feels a bit sloppy???

	for k, v in pairs(misc) do
		resource.AddFile("materials/niandralades/minigames/" .. v)
	end

	for k, v in pairs(icons) do
		resource.AddFile("materials/niandralades/minigames/mapicons/" .. v)
	end

else
	resource.AddWorkshop("621724216")
end

if Minigames:IsPlayingFreeForAll() then
	include("sh_freeforall.lua")
end

if Minigames:IsPlayingTwoVersusAll() then
	include("sh_twoversusall.lua")
end

if Minigames:IsPlayingAssaultCourse() then
	include("sh_assaultcourse.lua")
end

/*
if Minigames:IsPlayingTeamDeathmatch() then
	include("sh_teamdeathmatch.lua")
end
*/

if Minigames:IsPlayingTeamSurvival() then
	include("sh_teamsurvival.lua")
end

/*
if Minigames:IsPlayingCaptureTheFlag() then
	include("sh_capturetheflag.lua")
end
*/

function GM:ShowHelp(ply)
	net.Start("F_Help")
	net.Send(ply)
end

function GM:ShowTeam(ply)
	Minigames:ShowTeamSelect(ply)
end

local banned_weapons = {
  "weapon_knife",
  "weapon_oitc_pistol",
}

hook.Add( "KeyPress", "MG_DropWeapon", function( ply, key )
    local plywep = ply:GetActiveWeapon()
    if !ply:Alive() then return end
    if plywep == NULL then return end
    if Minigames:IsPlayingGunGame() == true then return end
    if !MG_CANDROPWEAPON then return end
    local plywepname = plywep:GetClass()

    if ( key == IN_ZOOM) then
        for k,v in pairs(banned_weapons) do  -- banned weapons check
          if plywepname == banned_weapons[k] then return end
        end
        ply:DropWeapon( ply:GetActiveWeapon() )
    end
end)

Minigames.MapWithWeapons = {
	"mg_pushcircle_night",
	"mg_hello_kitty_arena_v1b",
	"arena_castlewars",
	"arena_stroll",
	"arena_boxland"
}

Minigames.MapWithKnifesOnly = {
	"mg_ka_trains_detach",
	"mg_ka_trains",

}

Minigames.FFFNoDmg = {
	"mg_polar_panic_2",
	"mg_hbmadness_v2",
  "mg_stone_of_destiny_td",
}

Minigames.ForceFreeze = { --Ne pas mettre les maps 2VsAll, OITC et GunGame
	"mg_randomizer_v5_dg",
}

Minigames.OneVersusAll = {
	"mg_murder_driver_v3",
	"mg_ambush_v3"

}

function checkSqlPlayerSpec()
    if !sql.TableExists("player_isspec") then
        local query = "CREATE TABLE player_isspec ( steam_id64 text )"
        local result = sql.Query(query)
    end
end
checkSqlPlayerSpec()

net.Receive("Team_Select_Serverside", function(len,ply)
	local teamstring = net.ReadString()
	local plySpecReturn = sql.QueryValue("SELECT steam_id64 FROM player_isspec WHERE steam_id64='"..ply:SteamID64().."'" )

	if teamstring == "player" then
		if plySpecReturn then
            sql.QueryValue("DELETE FROM player_isspec WHERE steam_id64='"..ply:SteamID64().."'" )
		end

		if MG_MustJoinBlue == true or MG_isOneTeam == true then
			ply:SetTeam(TEAM_BLUE)
		else
			AutoChooseTeam(ply)
		end

	else
		if !plySpecReturn then
            sql.Query("INSERT INTO player_isspec (steam_id64) VALUES ('"..ply:SteamID64().."')")
		end

		Minigames:SetAFK(ply)
	end


	if ply:Team() == TEAM_RED or ply:Team() == TEAM_BLUE then
		if Minigames.RoundState == 1 then
			Minigames:PlayerJoinedDuringRound(ply)
		elseif Minigames.RoundState == 0 then
			Minigames:PlayerJoinedPreRound(ply)
		end
	end
end)

function Minigames:isPlayerShouldBeSpec(ply)
    if !ply:SteamID64() then return end
	if sql.QueryValue("SELECT steam_id64 FROM player_isspec WHERE steam_id64='"..ply:SteamID64().."'" ) then
		return true
	else
		return false
	end
end

hook.Add("PlayerInitialSpawn", "checkIfPlayerShouldBeSpecSQL", function(ply)
	timer.Simple(0.5,function()
		if Minigames:isPlayerShouldBeSpec(ply) then
			Minigames:SetAFK(ply)
		end
	end)
end)

net.Receive("MG_RequestRTVFromClient", function(len,ply)
	Minigames:PlayerRequestedRTV(ply)
end)

net.Receive("Minigames_WriteTeddy", function()

	local ent = net.ReadEntity()
	local pos = ent:GetPos()
	local ang = ent:GetAngles()

	local concat = tostring(pos) .. "/" .. tostring(ang)

	file.Write("minigames/" .. game.GetMap() .. ".txt",concat)
end)

function Minigames:PlayerConnectedPreround(ply)
	//do nothin by default
end

function MG_ShuffleTeam()
	if MG_isOneTeam then return end

	for k, v in RandomPairs(player.GetAll()) do
		if (v:Team() == TEAM_BLUE or v:Team() == TEAM_RED) then
			v:SetTeam(TEAM_UNASSIGNED)
		end
	end

	for k, v in RandomPairs(player.GetAll()) do
		if v:Team() != TEAM_SPECTATOR then
			AutoChooseTeam(v)
		end
	end

	//Avoir deux boucles separes assurent que tous les joueurs soient dans TEAM_UNASSIGNED
	//Avant de les remettre dans des équipes au hasard, sinon ca changerait pas grand choses.
end

function AutoChooseTeam(ply)
	local nbMembersBlue = #team.GetPlayers(TEAM_BLUE)
	local nbMembersRed = #team.GetPlayers(TEAM_RED)
	local nbMembersDifference = nbMembersBlue - nbMembersRed
	-- Valeur positive = il y a plus de joueurs Bleus
	-- Valeur négative = il y a plus de joueurs Rouges

	local tblRandomTeam = {TEAM_BLUE, TEAM_RED}

	if !MG_isOneTeam then
		if nbMembersDifference >= 1 then
			ply:SetTeam(TEAM_RED)
		elseif nbMembersDifference <= -1 then
			ply:SetTeam(TEAM_BLUE)
		else
			ply:SetTeam(table.Random(tblRandomTeam))
		end
	else
		ply:SetTeam(TEAM_BLUE)
	end

end

local weapons_tbl = {
	"weapon_ak47",
	"weapon_mac10",
	"weapon_m4a1",
	"weapon_tmp",
	"weapon_famas",
	"weapon_galil",
	"weapon_aug",
	"weapon_awp",
	"weapon_mp5",
	"weapon_p90",
	"weapon_scout",
	"weapon_ump45",
}

local seconday_tbl = {
	"weapon_deagle",
	"weapon_p228",
	"weapon_elite",
	"weapon_fiveseven",
	"weapon_glock",
	"weapon_usp",
}

function Minigames:GiveRandom(ply)
	if ply:Team() == TEAM_SPECTATOR or ply:Team() == TEAM_UNASSIGNED then return end
	ply:Give(table.Random(weapons_tbl))
	ply:Give(table.Random(seconday_tbl))
	ply:Give("weapon_knife")
end

function Minigames:ShowTeamSelect(ply)
	net.Start("Team_Select")
	net.Send(ply)
end


function GM:ScalePlayerDamage(ply, hitgroup, dmginfo)
    if hitgroup == HITGROUP_HEAD then
		local inflictor = dmginfo:GetInflictor()

		if IsValid(inflictor) and inflictor:IsPlayer() then
			local wep = inflictor:GetActiveWeapon()

            if IsValid(wep) and wep.GetHeadshotMultiplier then
                dmginfo:ScaleDamage(wep:GetHeadshotMultiplier())
            end
        end
    end
end

function GM:PlayerInitialSpawn(ply)
	net.Start("Minigames_PlyConnected")
	net.WriteString(ply:Name())
	net.WriteString(ply:SteamID())
	net.Broadcast()

	ply.PlayerModel = ply:GetPData("PlayerModel") or "models/player/kleiner.mdl"
	ply:AllowFlashlight(true)
	ply:SetCanZoom(false)
	ply:SetCustomCollisionCheck(true)

	if GetGlobalString("Minigames_CurrentGamemode") == "Minigames" then
		ply:SetTeam(TEAM_BLUE)
	end

	net.Start("MG_SendInitalData")
		net.WriteString(Minigames.RoundNumber)
		net.WriteString(Minigames.RoundLimit)
	net.Send(ply)

 	if Minigames.RoundState == 0 then
		print(timer.TimeLeft("RoundBeginTimer"))

		net.Start("MG_SendTimerPreRound")
		net.WriteFloat(timer.TimeLeft("RoundBeginTimer"))
		net.WriteFloat(CurTime())
		net.Send(ply)
	end

	timer.Simple(1, function()
		if Minigames.RoundState == 0 then
			Minigames:PlayerConnectedPreround(ply)
		else
			ply:KillSilent()
			ply:SetMoveType(MOVETYPE_NOCLIP)
		end
	end)
end

function GM:PlayerDisconnected(ply)
	net.Start("Minigames_PlyDisconnected")
	net.WriteString(ply:Name())
	net.WriteString(ply:SteamID())
	net.Broadcast()

	ply:SetPData("PlayerModel", ply.PlayerModel)

	if #player.GetAll() <= 1 then
		Minigames:RoundEnd(nil, nil)
		Minigames:CheckForPlayers()
	end
end

function GM:ShutDown()
	for k, v in pairs(player.GetAll()) do
		v:SetPData("PlayerModel", v.PlayerModel)
	end
end

--it's disabling the "beep beep" sound at death
function GM:PlayerDeathSound()
	return true
end


function GM:PlayerSpawn(ply)
	ply:SetModel(ply.PlayerModel or "models/player/arctic.mdl")

	if ply:GetModel() == "models/player.mdl" then
		ply.PlayerModel = "models/player/arctic.mdl"
		ply:SetModel(ply.PlayerModel)
		print("[minigames] you shouldn't see this message! (init.lua 335)")
	end

	ply:SetupHands()
	if not ply:IsGhostMode() then
		ply.OriginalTeam = ply:Team()
	end
	ply:UnSpectate()

	if Minigames.RoundState >= 0 then
		net.Start("Minigames_AvatarHUD")
			net.WriteBool(true)
		net.Send(ply)
	end

	ply:ConCommand("crosshair_enabled 1")

end

function GM:PlayerSwitchWeapon(ply, oldWeapon, newWeapon)
	ply:SetFOV(0,0)
end

function GM:PlayerDeath(ply,inflictor,attacker)
	ply:Freeze(false)
	ply:SetFOV(0,0)

	if Minigames.UsePointshop then
		if attacker:IsValid() and attacker ~= ply and attacker:IsPlayer() then
			attacker:SH_AddStandardPoints(Minigames.PointsPerKill)
			net.Start("Minigames_PointsOnKill")
				net.WriteString(attacker:Nick())
				net.WriteString(ply:Nick())
			net.Send(attacker)
		end

	elseif Minigames.UsePointshop_2 then
		if attacker:IsValid() and attacker ~= ply and attacker:IsPlayer() then
			attacker:PS2_AddStandardPoints(Minigames.PointsPerKill, "",true)
			net.Start("Minigames_PointsOnKill")
				net.WriteString(attacker:Nick())
				net.WriteString(ply:Nick())
			net.Send(attacker)
		end
	end

	net.Start("Minigames_AvatarHUD")
		net.WriteBool(false)
	net.Send(ply)

	net.Start("MG_Killfeed")
		net.WriteEntity(attacker)
		net.WriteEntity(ply)
	net.Broadcast()

	timer.Simple(0.5, function()
		ply:Spectate(OBS_MODE_ROAMING)
	end)

end

hook.Add("KeyPress", "SpeccySpec", function(ply,key)
	if ply:Alive() then return end
	local tbl = player.GetActive()
	local lastEnt = (table.KeyFromValue(tbl, ply:GetObserverTarget()) or 0)
	if key == IN_ATTACK then
		local entToSee = tbl[lastEnt+1]
		if !entToSee then lastEnt = 0 end
		ply:Spectate(OBS_MODE_CHASE)
		ply:SpectateEntity(tbl[lastEnt+1])

	elseif key == IN_ATTACK2 then
		ply:Spectate(OBS_MODE_ROAMING)


	elseif key == IN_RELOAD then
		ply:Spectate(OBS_MODE_IN_EYE)
	end

	net.Start("Minigames_SendSpecEntity")
	net.Send(ply)

end)

function GM:PlayerDeathThink()
end

hook.Add("KeyPress", "GhstMde", function(ply,key)
	if not GhostMode then return end

	if key == IN_ZOOM then
		GhostMode:ToggleGhostMode(ply)
	end
end)

net.Receive("Minigames_ChoosePlayerModel", function(len,ply)
	ply.PlayerModel = net.ReadString()
end)

function GM:PlayerCanPickupWeapon(ply,weapon)
	if ply:HasWeapon(weapon:GetClass()) then
		return false
	end

    for k, v in pairs(ply:GetWeapons()) do
        if weapon.Slot == v.Slot then
            return false
        end
    end

	return true
end

hook.Add( "StartCommand", "StartCommandExample", function( ply, cmd )
	if cmd==IN_SPEED then return end
end )

local fallsounds = {
   Sound("player/damage1.wav"),
   Sound("player/damage2.wav"),
   Sound("player/damage3.wav")
};

function GM:OnPlayerHitGround(ply, in_water, on_floater, speed)
    local speedLimitBeforeDamage = 600 --650 a la base
	if in_water or speed < speedLimitBeforeDamage or not IsValid(ply) then return end

   -- Everything over a threshold hurts you, rising exponentially with speed
   -- formule par defaut math.pow(0.05 * (speed - 420), 1.75)
   -- autre formule test : math.pow(0.08 * (speed - speedLimitBeforeDamage), 1.3)
   local damage = math.Round((math.pow(0.05 * (speed - speedLimitBeforeDamage), 1.3)), 0)

   -- I don't know exactly when on_floater is true, but it's probably when
   -- landing on something that is in water.
   if on_floater then damage = damage / 2 end

   -- if we fell on a dude, that hurts (him)
   local ground = ply:GetGroundEntity()
   if IsValid(ground) and ground:IsPlayer() then
	  if math.floor(damage) > 0 then
         local att = ply

         -- if the faller was pushed, that person should get attrib
         local push = ply.was_pushed
         if push then
            -- TODO: move push time checking stuff into fn?
            if math.max(push.t or 0, push.hurt or 0) > CurTime() - 4 then
               att = push.att
            end
         end

         local dmg = DamageInfo()

         if att == ply then
            -- hijack physgun damage as a marker of this type of kill
            dmg:SetDamageType(DMG_CRUSH + DMG_PHYSGUN)
         else
            -- if attributing to pusher, show more generic crush msg for now
            dmg:SetDamageType(DMG_CRUSH)
         end

         dmg:SetAttacker(att)
         dmg:SetInflictor(att)
         dmg:SetDamageForce(Vector(0,0,-1))
         dmg:SetDamage(damage)

		 ground:TakeDamageInfo(dmg)
      end

	  -- our own falling damage is cushioned
	  -- originalement a 3 mais trop op af (the fuck ca a lair de fucked up tout donc je laisse en comm)
      damage = damage / 3
   end

   if math.floor(damage) > 0 then
      local dmg = DamageInfo()
      dmg:SetDamageType(DMG_FALL)
      --dmg:SetAttacker(game.GetWorld())
      --dmg:SetInflictor(game.GetWorld())
      --dmg:SetDamageForce(Vector(0,0,1))
	  dmg:SetDamage(damage)

      if IsValid(ply) then ply:TakeDamageInfo(dmg) end

      -- play CS:S fall sound if we got somewhat significant damage
      if damage > 5 then
         sound.Play(table.Random(fallsounds), ply:GetShootPos(), 55 + math.Clamp(damage, 0, 50), 100)
      end
   end
end

-- PARCE QUE CE FUCKING CODER N A PAS COMPRIS QUE LES DEGATS PAR DEFAUTS DEVAIENT ETRE SUICIDE
function GM:GetFallDamage(ply, speed)
	return 0
end

-- Ce hook vérifie que le player n'est pas noclip en mode chelou
hook.Add("PlayerSpawn","CheckIfPlayerNoclipped",function(ply)
	timer.Simple(3,function()
		if ply:IsValid() then
			if ply:GetObserverMode() != 0 and ply:Alive() and (ply:Team() == TEAM_BLUE or ply:Team() == TEAM_RED) and Minigames.RoundState == 1 then --On vérifie que le joueur est dans une équipe, mais est en vision spec (il devrait donc spawn), on vérifie aussi que le round a commencé
				ply:ChatPrint("Looks like you broke something! Let me fix that.")
				ply:KillSilent() --On le tue, mais sans notifier les personnes
				ply:Spawn() --On le spawn, pas besoin de caractériser les positions et armes, les autres hooks devraient le faire car PlayerSpawn est enclenché
				ply:ChatPrint("I repaired you. Have a nice game !")
			end
		end
	end)
end)

hook.Add("PlayerSay", "ConfigCrosshairMenuSay", function(ply, text)
	if text == "!crosshair" then
		ply:ConCommand("open_crosshair_creator")
		return ""
	end
end)

hook.Add("PlayerSpawn", "ForceFreezeForMaps", function(ply)
	if table.HasValue(Minigames.ForceFreeze, game.GetMap()) then
		ply:Freeze(true)

		timer.Simple(6, function() ply:Freeze(false) end)
	end
end)

hook.Add("DoPlayerDeath", "ForceDropWeapons", function(ply)
    if !MG_CANDROPWEAPON then return end
	if IsValid(ply) and !Minigames:IsPlayingGunGame() then
		for k, v in pairs(ply:GetWeapons()) do
			if v.ClassName != "weapon_knife" then
				ply:DropWeapon(v)
			end
		end
	end
end)

timer.Create("AutoMSG_ThirdPerson",220, 0,function()
    for k, v in pairs(player.GetAll()) do
        if IsValid(v) then
            v:SendLua("chat.AddText(Color(0, 155, 95),\"You can customize your crosshair by typing !crosshair\")")
        end
    end
end)
