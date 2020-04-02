print("LOADED")

local MG_MvpPlayer = nil

local tbl_kills = {}
local tbl_timeSurvived = {}
local tbl_dmgGiven = {}
GLOBAL_mvp_timeSurvived = nil

hook.Add("RoundBegin","checkPlayersStatsForRound", function()
    MG_MvpPlayer = nil
    tbl_kills = {}
    tbl_timeSurvived = {}
    tbl_dmgGiven = {}

    for k, v in pairs(player.GetAll()) do
        if IsValid(v) and (v:Team() == TEAM_BLUE or v:Team() == TEAM_RED) then
            tbl_kills[v] = 0
            tbl_dmgGiven[v] = 0
            tbl_timeSurvived[v] = 0

        end
    end
    GLOBAL_mvp_timeSurvived = CurTime()
end)

hook.Add("PlayerDeath","checkRoundStatWhenDead",function(victim, inflictor, attacker)
    if Minigames.RoundState == 0 then return end
    local mvp_timeDead

    if IsValid(attacker) and IsValid(victim) and attacker:IsPlayer() and victim:IsPlayer() and victim != attacker then
        tbl_kills[attacker] = tbl_kills[attacker] + 1
    end

    if victim:IsPlayer() and IsValid(victim) then
        tbl_timeSurvived[victim] = CurTime() - GLOBAL_mvp_timeSurvived
    end

end)

hook.Add("EntityTakeDamage","checkRoundStatWhenDamage",function(victim, dmginfo)
    if Minigames.RoundState == 0 then return end

    local attacker = dmginfo:GetAttacker() or nil
    local damage = math.Round(dmginfo:GetDamage(), 0)

    if attacker:IsPlayer() and victim:IsPlayer() and IsValid(attacker) and IsValid(victim) and tbl_dmgGiven[attacker] and (attacker:Team() != victim:Team()) then
        tbl_dmgGiven[attacker] = tbl_dmgGiven[attacker] + damage
    end
end)


function MG_checkIfEqualMvpPlayer(tbl)
    local temp_value = 0
    for k, v in SortedPairsByValue(tbl, true) do
        if v > temp_value then
            temp_value = v
            MG_MvpPlayer = k
        elseif v == temp_value then
            return true
        end
    end
    return false
end


function MG_CheckMVPPlayerEnd()
    local argWhyMvp

    if GLOBAL_mvp_timeSurvived then
        for k, v in pairs(player.GetAll()) do
            if v:Alive() and IsValid(v) then
                tbl_timeSurvived[v] = CurTime() - GLOBAL_mvp_timeSurvived
            end
        end
    else
        print("GLOBAL_mvp_timeSurvived = NIL !")
    end

    if !MG_checkIfEqualMvpPlayer(tbl_kills) then
        argWhyMvp = "KILLS"
    else
        if !MG_checkIfEqualMvpPlayer(tbl_dmgGiven) then
            argWhyMvp = "DMG"
        else
            if !MG_checkIfEqualMvpPlayer(tbl_timeSurvived) then
                argWhyMvp = "TIME"
            else
                argWhyMvp = "NIL"
                MG_MvpPlayer = nil
            end
        end
    end

    if IsValid(MG_MvpPlayer) then
        print("MVP "..MG_MvpPlayer:Name().." BY: "..argWhyMvp)
    else
        print("MVP NOT VALID!")
    end


    local tblRet = {MG_MvpPlayer, argWhyMvp}
    return tblRet
end
