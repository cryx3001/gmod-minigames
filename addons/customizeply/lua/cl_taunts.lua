net.Receive("MG_SVtoCL_SendTaunKiller", function()
    local killer = net.ReadEntity()
    local tauntID = net.ReadInt(11)
    local heightFrame
    if tauntID != -1 and tauntID != nil then
        heightFrame = 140
    else
        heightFrame = 100
    end

    local frame = vgui.Create("DFrame")
    frame:SetSize(450, heightFrame)
    frame:SetDraggable(false)
    frame:ShowCloseButton(false)
    frame:SetTitle(" ")
    frame:SetPos(ScrW()/2-225, ScrH()+256) --ScrH()-256

    frame.Paint = function(self, w, h)
        draw.RoundedBox(0,0,0,w,h, Color(10,10,10,150))
        draw.DrawText("Killed by ","NexaLight35",94, 6,Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT)
        draw.DrawText(killer:Name(),"NexaLight40",94, 42, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT)
        draw.DrawText("Lvl: "..GLOBAL_LVLXPSTATS[killer:SteamID64().."_LVL"], "NexaLight30",440, 12, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT)

        if tauntID != -1 and tauntID != nil then
            draw.DrawText(MG_Taunts[tauntID]["Name"],"NexaLight25",32, 100, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT)
        end
    end

    frame:MoveTo(ScrW()/2-200, ScrH()-256, 0.2 )

    local avatar = vgui.Create("AvatarImage", frame)
    avatar:SetSize(64+8,64+8)
    avatar:SetPos(8,8)
    avatar:SetPlayer(killer, 64)

    if tauntID != -1 and tauntID != nil then
        local imageSound = vgui.Create("DImage", frame)
        imageSound:SetSize(16,16)
        imageSound:SetPos(10,106)
        imageSound:SetImage("icon16/sound")
    end


    timer.Simple(3, function()
        if frame then
            frame:MoveTo(ScrW()/2-200, ScrH()+256, 0.2, 0, -1, function() frame:Remove() end)
        end
    end)

    if tauntID != -1 and tauntID != nil then
        surface.PlaySound(MG_Taunts[tauntID]["Path"])
    end


end)
