if (CLIENT) then return end

util.AddNetworkString("LvlUpBroadcast")
util.AddNetworkString("LvlSendStats")
util.AddNetworkString("LvlSendNotiferLvlUp")
util.AddNetworkString("LVL_BroadcastStatsLevel")
util.AddNetworkString("XP_SendNotiferEarn")


local ply_meta = FindMetaTable("Player")
local level = "PlayerLevel"
local xp = "PlayerXp"


function initialize_sql()
    if !sql.TableExists("player_level") then
        local query = "CREATE TABLE player_level ( steam_id64 text, xp int, level int )"
        local result = sql.Query(query)
    end
end
initialize_sql()

function ply_meta:SetXP(amount)
    if self:IsBot() then return end
    self.xpValue = amount
    self:SendStatsXPLevel()
end


function ply_meta:AddXP(amount)
    if self:IsBot() then return end
    self.xpValue = self.xpValue + amount
    self:LevelUP()
    PlayerSaveXP_Level(self)
end


function AutoEarnXP(time, xp)
    timer.Create("AutoEarn", time, 0, function()
        for k, v in pairs(player.GetAll()) do
            if v:IsBot() then continue end
            v:AddXP(xp)
        end
    end)
end
AutoEarnXP(60, 1)


function ply_meta:GetXPNeeded()
    if self:IsBot() then return end
    self.supLevel = self.levelValue + 1
    self.xpNeeded = math.Round((15*math.pow(self.supLevel,1.2)+10),0)
    return self.xpNeeded
end


function ply_meta:LevelUP()
    if self:IsBot() then return end
    self.xpNeeded = self:GetXPNeeded()
    self.tempXP = self.xpValue

    if self.xpValue >= self.xpNeeded  then
        self.levelValue = self.levelValue  + 1
        self:SetXP(self.tempXP-self.xpNeeded)
        timer.Simple(1, function() self:BroadCastLevelUP() end)
    end
    self:SendStatsXPLevel()
end


function ply_meta:BroadCastLevelUP()
    local args = {Color(255,255,255), self, " is now ",Color(255,65,65), "level "..self.levelValue,Color(255,255,255),"!"}
    net.Start("LvlUpBroadcast")
    net.WriteTable(args)
    net.Broadcast(self)

    net.Start("LvlSendNotiferLvlUp")
    net.Send(self)
end


function ply_meta:SendStatsXPLevel()
    if self:IsBot() then return end
    tablXp = {
        tablXpValue = self.xpValue,
        tablLevelValue = self.levelValue,
        tablXpNeeded = self.xpNeeded
    }

    net.Start("LvlSendStats")
    net.WriteTable(tablXp)
    net.Send(self)

    LVL_BroadcastStatsLevel()
end

function LVL_BroadcastStatsLevel()
    local tblToSend = {}

    for k, v in pairs(player.GetAll()) do
        if v:IsBot() then continue end
        local vSteamID = v:SteamID64()
        local tempTbl = {
            [vSteamID.."_LVL"] = v.levelValue,
            [vSteamID.."_XP"] = v.xpValue,
            [vSteamID.."_XPNEEDED"] = v.xpNeeded,
        }

        table.Merge(tblToSend, tempTbl)
    end

    net.Start("LVL_BroadcastStatsLevel")
    net.WriteTable(tblToSend)
    net.Broadcast()
end



function DebugPrintXPLevel()
    timer.Create("ShowXPLevel", 3, 0, function()
        for k, v in pairs(player.GetAll()) do
            if v:IsBot() then continue end

            print(v:Name())
            print("LEVEL: "..v.levelValue)
            print("XP: "..v.xpValue)
            print("XP NEEDED: "..v:GetXPNeeded())
            print("  ")
            v:SendStatsXPLevel()
        end
    end)
end

function LoadPlayerXP(ply)
    if ply:IsBot() then return end
    local SQLXp = sql.QueryValue("SELECT xp FROM player_level WHERE steam_id64='"..ply:SteamID64().."'" )
    local SQLLevel = sql.QueryValue("SELECT level FROM player_level WHERE steam_id64='"..ply:SteamID64().."'" )

    if !SQLXp || !SQLLevel then
        sql.Query("INSERT INTO player_level (steam_id64, xp, level) VALUES ('"..ply:SteamID64().."', 0, 1)" )
        ply.xpValue = 0
        ply.levelValue = 1
    else
        ply.xpValue = SQLXp
        ply.levelValue = SQLLevel
    end

    ply.supLevel = ply.levelValue + 1
    ply.xpNeeded = ply:GetXPNeeded()
    ply:SendStatsXPLevel()
end
hook.Add("PlayerInitialSpawn", "InitLevelPlayer", LoadPlayerXP)

hook.Add("PlayerInitialSpawn","CheckLevelPlayer",function(ply)
    local xpToVerify = ply.xpValue
    local lvlToVerify = ply.levelValue
    local xpNeededToVerify = ply.xpNeeded
end)

function AutoSaveXP_Level()
    for k, v in pairs(player.GetAll()) do
        if v:IsBot() then continue end
        sql.Query("UPDATE player_level SET xp = "..v.xpValue..", level = "..v.levelValue.." WHERE steam_id64 = '"..v:SteamID64().."'")
    end
end
timer.Create("SQLUpdate", 60, 0, AutoSaveXP_Level)

function PlayerSaveXP_Level(ply)
    if ply:IsBot() then return end
    sql.Query("UPDATE player_level SET xp = "..ply.xpValue..", level = "..ply.levelValue.." WHERE steam_id64 = '"..ply:SteamID64().."'")
end


hook.Add("PlayerDeath", "EarnXPByKillingPeople", function(victim, inflictor, attacker)
    if attacker != victim and attacker:IsPlayer() and !attacker:IsBot() then
        attacker:AddXP(5)
        net.Start("XP_SendNotiferEarn")
        net.WriteString("Kill")
        net.WriteString(tostring(victim:GetName()))
        net.Send(attacker)
    end
end)


hook.Add("RoundEnd", "GiveXPWhenRoundEnd", function()
	if Minigames:IsPlayingFreeForAll() or Minigames:IsPlayingAssaultCourse() then
        local nbAlivePly = 0
        for k, v in pairs(player.GetAll()) do
            if v:Alive() then nbAlivePly = nbAlivePly + 1 end
        end

        if nbAlivePly == 1 then
    		for k, v in pairs(player.GetAll()) do
                if v:IsBot() then continue end
    			if v:Alive() then
                    v:AddXP(20)

                    net.Start("XP_SendNotiferEarn")
                    net.WriteString("XP_FFAWinner")
                    net.Send(v)
                end
    		end
        end
	else
		if MG_WinnerTeamReturn == TEAM_RED then
			for k, v in pairs(player.GetAll()) do
                if v:IsBot() then continue end
				if v:Team() == TEAM_RED then
                    v:AddXP(10)
                    if v:Alive() and Minigames:IsPlayingTeamSurvival() then
                        v:AddXP(5)
                        net.Start("XP_SendNotiferEarn")
                        net.WriteString("XP_TeamWinnerAndAlive")
                        net.WriteBool(v:Alive())
                        net.Send(v)
                        continue
                    end

                    net.Start("XP_SendNotiferEarn")
                    net.WriteString("XP_TeamWinner")
                    net.WriteBool(v:Alive())
                    net.Send(v)
                end
			end

		elseif MG_WinnerTeamReturn == TEAM_BLUE then
			for k, v in pairs(player.GetAll()) do
                if v:IsBot() then continue end
				if v:Team() == TEAM_BLUE then v:AddXP(5)
                    if v:Alive() then
                        v:AddXP(10)
                        net.Start("XP_SendNotiferEarn")
                        net.WriteString("XP_TeamWinnerAndAlive")
                        net.Send(v)
                        continue
                    end

                    net.Start("XP_SendNotiferEarn")
                    net.WriteString("XP_TeamWinner")
                    net.Send(v)
                end
			end
		end

	end
end)
