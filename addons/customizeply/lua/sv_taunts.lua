print("SV TAUNTS LOADED")
util.AddNetworkString("MG_CLtoSV_UpdateInventory")
util.AddNetworkString("MG_SVtoCL_NotifyPlayer")
util.AddNetworkString("MG_SVtoCL_SendInventory")
util.AddNetworkString("MG_SVtoCL_SendTaunKiller")

local playerTaunt = FindMetaTable("Player")


local function initialize_sql_taunts()
    if !sql.TableExists("player_taunts") then
        local query = "CREATE TABLE player_taunts ( steam_id64 text, have_taunts text, equipped_one int )"
        local result = sql.Query(query)
    end
end
initialize_sql_taunts()


/*
timer.Create("checkSqlTimer",10,0,function()
    print(sql.LastError())
    for k, v in pairs(player.GetAll()) do print(v.equippedTaunt) end
end)
*/

hook.Add("PlayerAuthed","checkPlayerTauntsEquipper",function(ply)
    local plySteam = ply:SteamID64()
    local SQLTaunts = sql.QueryValue("SELECT have_taunts FROM player_taunts WHERE steam_id64='"..ply:SteamID64().."'" )
    if !SQLTaunts then
        sql.Query("INSERT INTO player_taunts (steam_id64) VALUES ('"..ply:SteamID64().."')" )
        ply.tblTaunts = {}
        ply.equippedTaunt = nil
    else
        ply.tblTaunts = util.JSONToTable(SQLTaunts) or {}
        ply.equippedTaunt = sql.QueryValue("SELECT equipped_one FROM player_taunts WHERE steam_id64='"..ply:SteamID64().."'" ) or nil
    end

    ply.equippedTaunt = tonumber(ply.equippedTaunt)

    local inventoryInfo = {ply.tblTaunts, ply.equippedTaunt}
    --print("EQUIPPED "..inventoryInfo[2])
    net.Start("MG_SVtoCL_SendInventory")
    net.WriteTable(inventoryInfo)
    net.Send(ply)

end)

local function netMessageTauntServer(id, why, ply)
    net.Start("MG_SVtoCL_NotifyPlayer")
    net.WriteString(why)
    net.WriteInt(id,11)
    net.Send(ply)
end

net.Receive("MG_CLtoSV_UpdateInventory", function(len, ply)
    local id = net.ReadInt(11)
    local whatDoesHeWant = net.ReadString()

    --print("NET OK WITH ID "..id.." AND ARG "..whatDoesHeWant)

    if whatDoesHeWant == "BUY" then
        if ply:SH_CanAffordStandard(MG_Taunts[id]["Price"]) then
            ply:SH_SetStandardPoints(ply:SH_GetStandardPoints()-MG_Taunts[id]["Price"])
            table.insert(ply.tblTaunts, MG_Taunts[id]["ID"])
            sql.Query("UPDATE player_taunts SET have_taunts = '"..util.TableToJSON(ply.tblTaunts).."' WHERE steam_id64 = '"..ply:SteamID64().."'")
            netMessageTauntServer(id, "BUY", ply)
        end

    elseif whatDoesHeWant == "EQUIP" then
        netMessageTauntServer(id, "EQUIP", ply)
        ply.equippedTaunt = id
        sql.Query("UPDATE player_taunts SET equipped_one = '"..ply.equippedTaunt.."' WHERE steam_id64 = '"..ply:SteamID64().."'")

    elseif whatDoesHeWant == "UNEQUIP" then
        netMessageTauntServer(id, "UNEQUIP", ply)
        ply.equippedTaunt = nil
        sql.Query("UPDATE player_taunts SET equipped_one = Null WHERE steam_id64 = '"..ply:SteamID64().."'")
    end
end)

hook.Add("PlayerDeath", "freezeCamPlayerDeath", function(victim, weapon, killer)
	if !killer:IsPlayer() then return end
	--if victim == killer then return end

	victim:Spectate(OBS_MODE_DEATHCAM)
	victim:SpectateEntity( killer )

	timer.Simple(1, function()
		if !IsValid(killer) then return end
		victim:Spectate(OBS_MODE_FREEZECAM)
		victim:SpectateEntity( killer )
	end)

    net.Start("MG_SVtoCL_SendTaunKiller")
    net.WriteEntity(killer)
    net.WriteInt(killer.equippedTaunt or -1, 11 )
    net.Send(victim)
end)


hook.Add("PlayerSay","destroySqlPlayerTaunts",function(ply, text, team)
    if text == "!destroy" then
        --print("deleted")

        sql.Query("UPDATE player_taunts SET have_taunts = Null")
        ply.tblTaunts = nil
        ply.equippedTaunt = nil
    end
end)
