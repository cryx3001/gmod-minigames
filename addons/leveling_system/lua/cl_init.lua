if(SERVER) then return end

surface.CreateFont("BigFuckingText1", {
    font = "Arial",
    extended = false,
    size = 40,
    weight = 5000,
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
})


surface.CreateFont("BigFuckingText2", {
    font = "Arial",
    extended = false,
    size = 80,
    weight = 5000,
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
})


net.Receive("LvlUpBroadcast", function()
    local args = net.ReadTable()
    chat.AddText(unpack(args))
end)

GLOBAL_LVLXPSTATS = {}
net.Receive("LVL_BroadcastStatsLevel", function()
    GLOBAL_LVLXPSTATS = net.ReadTable()
end)

function LevelUpHud()
    draw.DrawText("RANK UP!", "BigFuckingText1", ScrW()/2, ScrH()/5, Color(50,100,193,250), TEXT_ALIGN_CENTER)
    draw.DrawText("LEVEL "..tostring(level), "BigFuckingText2", ScrW()/2, ScrH()/4, Color(200,50,50,250), TEXT_ALIGN_CENTER)
end


net.Receive("XP_SendNotiferEarn", function()
    local arg = net.ReadString()
    local victim = net.ReadString()
    local timerBool = true

    hook.Add("HUDPaint", "HUDPaint_EarnXPNotifer", function()
        if timerBool then
            if arg == "Kill" then
                draw.DrawText("Killed "..victim, "Trebuchet24", (ScrW()/2)+10, (ScrH()/1.4)-50, Color(255,255,255,255), TEXT_ALIGN_RIGHT)
                draw.DrawText("5 XP", "Trebuchet24", (ScrW()/2)+100, (ScrH()/1.4)-50, Color(0,150,50,255), TEXT_ALIGN_LEFT)
                draw.DrawText("1 COIN", "Trebuchet24", (ScrW()/2)+100, (ScrH()/1.4)+20-50, Color(255,255,0,255), TEXT_ALIGN_LEFT)
            end

            if arg == "XP_FFAWinner" then
                draw.DrawText("Winner", "Trebuchet24", (ScrW()/2)+10, (ScrH()/1.4)-50, Color(255,255,255,255), TEXT_ALIGN_RIGHT)
                draw.DrawText("20 XP", "Trebuchet24", (ScrW()/2)+100, (ScrH()/1.4)-50, Color(0,150,50,255), TEXT_ALIGN_LEFT)
                draw.DrawText("20 COINS", "Trebuchet24", (ScrW()/2)+100, (ScrH()/1.4)+20-50, Color(255,255,0,255), TEXT_ALIGN_LEFT)

            elseif arg == "XP_TeamWinner" then
                draw.DrawText("Winner", "Trebuchet24", (ScrW()/2)+10, (ScrH()/1.4)-50, Color(255,255,255,255), TEXT_ALIGN_RIGHT)
                draw.DrawText("10 XP", "Trebuchet24", (ScrW()/2)+100, (ScrH()/1.4)-50, Color(0,150,50,255), TEXT_ALIGN_LEFT)
                draw.DrawText("5  COINS", "Trebuchet24", (ScrW()/2)+100, (ScrH()/1.4)+20-50, Color(255,255,0,255), TEXT_ALIGN_LEFT)

            elseif arg == "XP_TeamWinnerAndAlive" then
                draw.DrawText("Winner", "Trebuchet24", (ScrW()/2)+10, (ScrH()/1.4)-50, Color(255,255,255,255), TEXT_ALIGN_RIGHT)
                draw.DrawText("10 XP", "Trebuchet24", (ScrW()/2)+100, (ScrH()/1.4)-50, Color(0,150,50,255), TEXT_ALIGN_LEFT)
                draw.DrawText("5 COINS", "Trebuchet24", (ScrW()/2)+100, (ScrH()/1.4)+20-50, Color(255,255,0,255), TEXT_ALIGN_LEFT)

                draw.DrawText("Still alive!", "Trebuchet24", (ScrW()/2)+10, (ScrH()/1.4)+50-50, Color(255,255,255,255), TEXT_ALIGN_RIGHT)
                draw.DrawText("5  XP", "Trebuchet24", (ScrW()/2)+100, (ScrH()/1.4)+50-50, Color(0,150,50,255), TEXT_ALIGN_LEFT)
            end
        end

        timer.Simple(5,function() timerBool = false end)
    end)
end)

local p = 100
local o = 130
local oTwo = 180
local h = 60
local hTwo = 90

local i = 0
local k = 2

local level
local xp
local xpNeeded
local levelbaricon = Material("icon16/status_online.png")

net.Receive("LvlSendStats", function()
    local tablXp = net.ReadTable()

    xp = tablXp.tablXpValue
    level = tablXp.tablLevelValue
    xpNeeded = tablXp.tablXpNeeded
end)

hook.Add("HUDPaint" , "LevelxpbarHUD", function()
	if !LocalPlayer():Alive() then return end
	if Minigames.CustomHUD then return end
	if Minigames.ScoreboardOpen then return end
	if Minigames.MapvoteOpen then return end

	draw.DrawText("Level "..level ,"NexaLight30", p-o/k + 18, ScrH()-12-20-64-32-24-4)
	draw.RoundedBox( 0 , p - o/k , ScrH()-12-20-64-32 , 175 , 15, Color(0,0,0,150))
	draw.RoundedBox( 0 , p - o/k , ScrH()-12-20-64-32 , (xp/xpNeeded)*175 , 15, Color(0, 191, 255 ,160))
	draw.DrawText(xp.."/"..xpNeeded ,"NexaLight15", p-o/k + 90, ScrH()-12-20-64-32, Color(255, 255, 255), TEXT_ALIGN_CENTER )
	surface.SetMaterial(levelbaricon)
	surface.DrawTexturedRect(p-o/k, ScrH()-12-20-64-32-24 + 5, 16, 16)
end)



--Need edit
/*
net.Receive("LvlSendNotiferLvlUp",function()
    hook.Add("HUDPaint", "HUDPaint_LevelUpHud", LevelUpHud)
    timer.Simple(5,function() hook.Remove("HUDPaint", "HUDPaint_LevelUpHud") end)
end)


hook.Add("HUDPaint", "HUDPaint_LevelInfo", function()
    draw.DrawText(tostring(xp).." / "..tostring(xpNeeded), "Trebuchet24", ScrW()/100, ScrH()/100, Color(255,255,255), TEXT_ALIGN_LEFT)
    draw.DrawText("Level "..tostring(level), "Trebuchet24", ScrW()/100, ScrH()/30, Color(255,255,255), TEXT_ALIGN_LEFT)
end)
*/
