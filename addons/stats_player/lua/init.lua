if (CLIENT) then return end

util.AddNetworkString("STATS_BroadcastStats")

local ply_meta = FindMetaTable("Player")

local kills = "PlayerKills"
local deaths = "PlayerDeaths"
local roundsPlayed = "RoundsPlayed"
local roundsWon = "RoundsWon"
local shotsHs = "ShotsHs"
local shotsTouched = "ShotsTouched"
local shotsFired = "ShotsFired"
local damageGiven = "DamageGiven"
local damageReceived = "DamageReceived"



function initialize_sql_statsplayer()
    if !sql.TableExists("player_stats") then
        query = "CREATE TABLE player_stats ( steam_id64 text, kills int, deaths int, roundsPlayed int, roundsWon int, shotsHs int, shotsTouched int, shotsFired int, damageGiven int, damageReceived int )"
        result = sql.Query(query)
    end
end
initialize_sql_statsplayer()


hook.Add("PlayerInitialSpawn", "InitStatsPlayer", function(ply)
    if ply:IsBot() then return end

    local SQLKills = sql.QueryValue("SELECT kills FROM player_stats WHERE steam_id64='"..ply:SteamID64().."'" )
    local SQLDeaths = sql.QueryValue("SELECT deaths FROM player_stats WHERE steam_id64='"..ply:SteamID64().."'" )
    local SQLRoundsPlayed = sql.QueryValue("SELECT roundsPlayed FROM player_stats WHERE steam_id64='"..ply:SteamID64().."'" )
    local SQLRoundsWon = sql.QueryValue("SELECT roundsWon FROM player_stats WHERE steam_id64='"..ply:SteamID64().."'" )
    local SQLShotsFired = sql.QueryValue("SELECT shotsFired FROM player_stats WHERE steam_id64='"..ply:SteamID64().."'" )
    local SQLShotsHs = sql.QueryValue("SELECT shotsHs FROM player_stats WHERE steam_id64='"..ply:SteamID64().."'" )
    local SQLShotsTouched = sql.QueryValue("SELECT shotsTouched FROM player_stats WHERE steam_id64='"..ply:SteamID64().."'" )
    local SQLDamageGiven = sql.QueryValue("SELECT damageGiven FROM player_stats WHERE steam_id64='"..ply:SteamID64().."'" )
    local SQLDamageReceived = sql.QueryValue("SELECT damageReceived FROM player_stats WHERE steam_id64='"..ply:SteamID64().."'" )

    if !SQLKills || !SQLDeaths || !SQLRoundsPlayed || !SQLShotsFired then
        local test = sql.Query("INSERT INTO player_stats (steam_id64, kills, deaths, roundsPlayed, roundsWon, shotsHs, shotsTouched, shotsFired, damageGiven, damageReceived) VALUES ('"..ply:SteamID64().."', 0, 0, 0, 0, 0, 0, 0, 0, 0)" )

        ply.STATS_kills = 0
        ply.STATS_deaths = 0
        ply.STATS_roundsPlayed = 0
        ply.STATS_roundsWon = 0
        ply.STATS_shotsFired = 0
        ply.STATS_shotsHs = 0
        ply.STATS_shotsTouched = 0
        ply.STATS_damageGiven = 0
        ply.STATS_damageReceived = 0
    else
        ply.STATS_kills = SQLKills
        ply.STATS_deaths = SQLDeaths
        ply.STATS_roundsPlayed = SQLRoundsPlayed
        ply.STATS_roundsWon = SQLRoundsWon
        ply.STATS_shotsFired = SQLShotsFired
        ply.STATS_shotsHs = SQLShotsHs
        ply.STATS_shotsTouched = SQLShotsTouched
        ply.STATS_damageGiven = SQLDamageGiven
        ply.STATS_damageReceived = SQLDamageReceived
    end
end)

function DebugStatsPlayer()
    timer.Create("StatsPlayerDebug",5,0,function()
        for k, v in pairs(player.GetAll()) do
            if v:IsBot() then continue end

            print("NAME "..v:Name())
            print("KILLS "..v.STATS_kills)
            print("DEATHS "..v.STATS_deaths)
            print("ROUNDS PLAYED "..v.STATS_roundsPlayed)
            print("ROUNDS WON "..v.STATS_roundsWon)
            print("SHOTS FIRED "..v.STATS_shotsFired)
            print("SHOTS HS "..v.STATS_shotsHs)
            print("SHOTS TOUCHED "..v.STATS_shotsTouched)
            print("DMG GIVEN "..v.STATS_damageGiven)
            print("DMG RECEIVED "..v.STATS_damageReceived)
            print("")
        end
    end)
end
--DebugStatsPlayer()


function AutoSaveStatsPlayer()
    for k, v in pairs(player.GetAll()) do
        if v:IsBot() then continue end
        sql.Query("UPDATE player_stats SET kills = "..v.STATS_kills..", deaths = "..v.STATS_deaths..", roundsPlayed = "..v.STATS_roundsPlayed..", roundsWon= "..v.STATS_roundsWon..", shotsHs = "..v.STATS_shotsHs..", shotsTouched = "..v.STATS_shotsTouched..", shotsFired = "..v.STATS_shotsFired..", damageGiven = "..v.STATS_damageGiven..", damageReceived = "..v.STATS_damageReceived.." WHERE steam_id64 = '"..v:SteamID64().."'")
    end
end
timer.Create("SQLUpdateStatsPly", 20, 0, AutoSaveStatsPlayer)

function STATS_SendToClient()
    local tblToSend = {}

    for k, v in pairs(player.GetAll()) do
        if v:IsBot() then continue end
        local vSteamID = v:SteamID64()
        local tempTbl = {
            [vSteamID.."_KILLS"] = tostring(v.STATS_kills),
            [vSteamID.."_DEATHS"] = tostring(v.STATS_deaths),
            [vSteamID.."_PLAYED"] = tostring(v.STATS_roundsPlayed),
            [vSteamID.."_WON"] = tostring(v.STATS_roundsWon),
            [vSteamID.."_FIRED"] = tostring(v.STATS_shotsFired),
            [vSteamID.."_HS"] = tostring(v.STATS_shotsHs),
            [vSteamID.."_TOUCHED"] = tostring(v.STATS_shotsTouched),
            [vSteamID.."_GIVEN"] = tostring(v.STATS_damageGiven),
            [vSteamID.."_RECEIVED"] = tostring(v.STATS_damageReceived),
            [vSteamID.."_PSPOINT"] = tostring(v:SH_GetStandardPoints()),
        }

        table.Merge(tblToSend, tempTbl)
    end

    net.Start("STATS_BroadcastStats")
    net.WriteTable(tblToSend)
    net.Broadcast()
end

hook.Add("RoundEnd", "GiveStatsRound", function()
    for k, v in pairs(player.GetAll()) do
        if v:IsBot() then continue end

        v.STATS_roundsPlayed = v.STATS_roundsPlayed + 1

        if Minigames:IsPlayingFreeForAll() or Minigames:IsPlayingAssaultCourse() then
    		if v:Alive() then v.STATS_roundsWon = v.STATS_roundsWon + 1 end

    	else

    		if MG_WinnerTeamReturn == TEAM_RED then
                if v:IsBot() then continue end
				if v:Team() == TEAM_RED then v.STATS_roundsWon = v.STATS_roundsWon + 1 end


    		elseif MG_WinnerTeamReturn == TEAM_BLUE then
                if v:IsBot() then continue end
				if v:Team() == TEAM_BLUE then v.STATS_roundsWon = v.STATS_roundsWon + 1 end
    		end
        end
    end
end)

hook.Add("PlayerDeath","CountPlyDeathAndKill", function(victim, inflictor, attacker)
    if victim != attacker and attacker:IsPlayer() and !attacker:IsBot() then
        attacker.STATS_kills = attacker.STATS_kills + 1
    end

    if !victim:IsBot() then victim.STATS_deaths = victim.STATS_deaths + 1 end
end)


hook.Add("EntityTakeDamage","CountDamageInformationsSTATS",function(victim, dmginfo)
    local attacker = dmginfo:GetAttacker()
    local damage = dmginfo:GetDamage()

    if !victim:IsPlayer() then return end
    if attacker:IsPlayer() then
        if attacker:Team() == victim:Team() then return end
    end
    if damage > 500  /* or victim:IsBot() or attacker:IsBot() */ then return end

    if dmginfo:IsDamageType(2) or dmginfo:IsDamageType(8194)  then
        if victim:LastHitGroup() == 1 then
            attacker.STATS_shotsHs = attacker.STATS_shotsHs + 1
        end
    end

    if !victim:IsBot() then
        victim.STATS_damageReceived = math.Round(victim.STATS_damageReceived + damage, 0)
    end


    if attacker != victim and attacker:IsPlayer() then
        attacker.STATS_damageGiven = math.Round(attacker.STATS_damageGiven + damage, 0)
        attacker.STATS_shotsTouched =  math.Round(attacker.STATS_shotsTouched + 1, 0)
    end
end)

timer.Create("STATS_AutoSendStats",1,0,STATS_SendToClient)
