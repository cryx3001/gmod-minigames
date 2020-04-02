print("CL MENU LOADED")

concommand.Add("open_customizeply", function()
    CustomizePlyOpenMenu()
end)

local pressed_key
local isItMoved = false
local frame
local statusItem = {}
local startWithStringTrigger = {
    "u",
    "b",
    "g",
    "r",
    "c",
    "u",
    "f",
    "/",
}

hook.Add("Think", "F3ToOpenShopMenu", function()
    --print(_SH_POINTSHOP)
    if input.IsKeyDown(KEY_F3) and not pressed_key then
		pressed_key = true

		if frame == nil or not frame:IsValid() then
			CustomizePlyOpenMenu()
		else
			frame:Close()

            if _SH_POINTSHOP then
                if _SH_POINTSHOP:IsValid() then
                    _SH_POINTSHOP:Close()
                end
            end
		end

	elseif pressed_key and not input.IsKeyDown(KEY_F3) then
		pressed_key = false
	end
end)


function CustomizePlyAdjustMenu(wi, posX, msgArg)
    --Lorsque qu on appuie sur le btn ajuster du pointshop
    --LocalPlayer():ChatPrint("CALLED WITH "..(wi or "nil").."/"..(posX or "nil").."/"..(msgArg or "nil"))

    local origY = (ScrH()/2)-frame:GetTall()/2
    local origX = (ScrW()/2)-frame:GetWide()/2

    if msgArg == "GoToNew" then
        frame:MoveTo(_SH_POINTSHOP.x - wi * 0.5, origY, 0.3)
        isItMoved = true

    elseif msgArg == "GoToOrig" then
        frame:MoveTo(posX, origY, 0.3)
        isItMoved = false
    else
        frame:MoveTo(origX, origY, 0.1)
        isItMoved = false
    end
end

local function countStringTextTitle(string)
    local len = string.len(string)
    local origLen = len

    local splited = string.Split(string,"")
    local triggerDelete = false

    for k, v in pairs(splited) do
        if v == "<" and table.HasValue(startWithStringTrigger,splited[k+1]) then
            --print(v)
            --print(splited[k+1])
            len = len-1
            triggerDelete = true

        elseif v == ">" and triggerDelete then
            triggerDelete = false
        end


        if triggerDelete then
            len = len - 1
            --print("DELETED "..len)
        end
    end
    --print("Orig "..origLen)
    --print("New "..len)

    return len
end

function CustomizePlyOpenMenu()
    frame = vgui.Create( "DFrame" )
    frame:SetSize( 900, 750)
    frame:MakePopup()                                  -- Main window
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(false)
    frame:ShowCloseButton(true)
    frame.Paint = function()
      draw.RoundedBox(0,0,0, frame:GetWide(), frame:GetTall(),Color(26, 26, 26, 220))
      draw.DrawText("Shop","NexaLight40",10,20,Color( 255, 255, 255, 255 ),TEXT_ALIGN_LEFT)
    end
    frame.OnClose = function ()
        if _SH_POINTSHOP then
            if _SH_POINTSHOP:IsValid() then
                _SH_POINTSHOP:Close()
            end
        end

        if isItMoved then
            CustomizePlyAdjustMenu()
        end
    end

    local sheetPanel = vgui.Create("DPropertySheet", frame)
    sheetPanel:SetSize(frame:GetWide()-20, frame:GetTall()-100)
    sheetPanel:SetPos(10, 80)
    sheetPanel.Paint = function()
        draw.RoundedBox(0,0,0,sheetPanel:GetWide(), sheetPanel:GetTall(),Color(0,0,0,0))
    end

    -- Partie Titre
    local textEntered
    local maxCharacters = 25

    local titlesSheet = vgui.Create("DScrollPanel", sheetPanel)
    titlesSheet.Paint = function(self, w, h)
        draw.RoundedBox(0,0,0,w,h,Color(0,0,0,0))
        draw.DrawText("This is an anticipated feature not linked to our database.\n Your title will be reset every time the map change.\nPlease refer any bugs/issues.","NexaLight35",w/2,h/5,Color( 255, 255, 255, 255 ),TEXT_ALIGN_CENTER)
        draw.DrawText("Available effects: \n- <b>Your bolded text<b>\n- <u>Your underlined text<u>\n- <color=colorName>Your text with color</color>\n- <glow>Your glowed text</glow>\n- <glowflash=flashSpeed>Your glowed flashing text</glowflash>\n- <rainbow=cycleSpeed>Your text with rainbow colors</rainbow>\n- <flash=colorName,flashSpeed>Your flashing text</flash>\n- You can combine effects together: <u><color=red>My red underlined text</color><u>","NexaLight20",0, 420, Color( 255, 255, 255, 255 ),TEXT_ALIGN_LEFT)
    end

    local textEntryTitles = vgui.Create( "DTextEntry", titlesSheet ) -- create the form as a child of frame
    textEntryTitles:SetPos(325-50, 300)
    textEntryTitles:SetSize( 400, 20 )
    textEntryTitles:SetText( "" )
    textEntryTitles:SetUpdateOnType(true)
    textEntryTitles.OnChange = function()
        textEntered = textEntryTitles:GetValue()
    end

    local visualizeTitle = vgui.Create("DButton", titlesSheet)
    visualizeTitle:SetPos(325-50,330)
    visualizeTitle:SetSize(190,50)
    visualizeTitle:SetText(" ")
    visualizeTitle.Paint = function(self, w, h)
        draw.RoundedBox(0,0,0, w, h,Color(20,20,20,255))
        draw.DrawText("Visualize","NexaLight25",w/2, 10,Color( 255, 255, 255, 255 ),TEXT_ALIGN_CENTER)
    end

    visualizeTitle.DoClick = function()
        if textEntered and textEntered != "" then
            LocalPlayer():ChatPrint(textEntered)
            LocalPlayer():ChatPrint(countStringTextTitle(textEntered).. " characters used, max = "..maxCharacters)
            --PrintTable(string.Split(textEntered, ""))
        else
            LocalPlayer():ChatPrint("You should type something to visualize anything. If you save this, your title will be removed.")
        end
    end

    local saveTitle = vgui.Create("DButton", titlesSheet)
    saveTitle:SetPos(325+160,330)
    saveTitle:SetSize(190,50)
    saveTitle:SetText(" ")
    saveTitle.Paint = function(self, w, h)
        draw.RoundedBox(0,0,0, w, h,Color(20,20,20,255))
        draw.DrawText("Save","NexaLight25",w/2, 10,Color( 255, 255, 255, 255 ),TEXT_ALIGN_CENTER)
    end
    saveTitle.DoClick = function()
        if textEntered == nil or textEntered == "" then
            textEntered = "NIL_VALUE$"
        end

        if countStringTextTitle(textEntered) <= maxCharacters then
            LocalPlayer():ChatPrint("Title accepted!")
            net.Start("SH_SendToServer_Title")
                net.WriteString(LocalPlayer():SteamID64())
                net.WriteString(textEntered)
            net.SendToServer()

        else
            LocalPlayer():ChatPrint("Your text is way too long! "..countStringTextTitle(textEntered).. " characters / MAX = "..maxCharacters)
        end
    end



    local titleButton = sheetPanel:AddSheet("Titles", titlesSheet, "icon16/comment.png")["Tab"]
    function titleButton:GetTabHeight() return 20 end
    function titleButton:DoRightClick() return end

    titleButton:SetFont("NexaLight25")
    titleButton:SetText("         ")
    titleButton.Paint = function(self, w, h)
        --draw.RoundedBox(0,0,0, w, h, Color(0,0,255,100))
        draw.DrawText("Titles","NexaLight25",28,-3,Color( 255, 255, 255, 255 ),TEXT_ALIGN_LEFT)
    end

    titleButton.DoClick = function()
       titleButton:GetPropertySheet():SetActiveTab( titleButton )
       LocalPlayer():ChatPrint("<rainbow=5> Colored! </rainbow>")

       if _SH_POINTSHOP then
           if _SH_POINTSHOP:IsValid() then
               _SH_POINTSHOP:Close()
           end
       end

       if isItMoved then
           CustomizePlyAdjustMenu()
       end

    end


    -- Partie Sound
    local function sendNetMessageForTaunt(id, why)
        net.Start("MG_CLtoSV_UpdateInventory")
        net.WriteInt(id, 11)
        net.WriteString(why)
        net.SendToServer()
    end

    local soundsSheet = vgui.Create("DScrollPanel", sheetPanel)
    soundsSheet.Paint = function(self, w, h)
        draw.RoundedBox(0,0,0, w, h, Color(0,0,0,0))
    end

    local sbar = soundsSheet:GetVBar()

    function sbar:Paint( w, h ) draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 100 ) ) end
    function sbar.btnUp:Paint( w, h ) draw.RoundedBox( 0, 0, 0, w, h, Color( 50, 50, 50, 180 ) ) end
    function sbar.btnDown:Paint( w, h ) draw.RoundedBox( 0, 0, 0, w, h, Color( 50, 50, 50, 180 ) ) end
    function sbar.btnGrip:Paint( w, h ) draw.RoundedBox( 0, 0, 0, w, h, Color( 40, 40, 40, 180) ) end

    local soundButton = sheetPanel:AddSheet("Sounds", soundsSheet, "icon16/sound.png")["Tab"]
    function soundButton:GetTabHeight() return 20 end
    function soundButton:DoRightClick() return end
    soundButton:SetFont("NexaLight25")
    soundButton:SetText("            ")
    soundButton.Paint = function(self, w, h)
        --draw.RoundedBox(0,5,0, w-5, h, Color(0,255,0,100))
        draw.DrawText("Sounds","NexaLight25",28,-3,Color( 255, 255, 255, 255 ),TEXT_ALIGN_LEFT)
    end

    soundButton.DoClick = function()
       soundButton:GetPropertySheet():SetActiveTab( soundButton )

       if _SH_POINTSHOP then
           if _SH_POINTSHOP:IsValid() then
               _SH_POINTSHOP:Close()
           end
       end

       if isItMoved then
           CustomizePlyAdjustMenu()
       end
    end


    local newHeight = 0
    for k, v in pairs(MG_Taunts) do

        local itemSound = vgui.Create("DPanel", soundsSheet)
        itemSound:SetPos(10, newHeight)
        itemSound:SetSize(930,60) --620
        itemSound.Paint = function(self, w, h)
            draw.RoundedBox(0,0,0, w, h, Color(30,30,30,255))
            draw.DrawText(v["Name"],"NexaLight25", 5, 5, Color( 255, 255, 255, 255 ),TEXT_ALIGN_LEFT)
            draw.DrawText(v["Price"].." Coins","NexaLight25", 5, 30, Color( 255, 255, 255, 255 ),TEXT_ALIGN_LEFT)
        end

        local buyItemSound = vgui.Create("DButton", itemSound)
        buyItemSound:SetPos(750,5)
        buyItemSound:SetSize(80,50)
        buyItemSound:SetText(" ")
        buyItemSound.Paint = function(self, w, h)
            if statusItem[v["ID"]] == nil then
                draw.RoundedBox(0,0,0, w, h,Color(50,50,50,150))
                draw.DrawText("Buy","NexaLight25",w/2, 10,Color( 255, 255, 255, 255 ),TEXT_ALIGN_CENTER)
            elseif statusItem[v["ID"]] == 1 then
                draw.RoundedBox(0,0,0, w, h,Color(0,50,0,150))
                draw.DrawText("Equip","NexaLight25",w/2, 10,Color( 255, 255, 255, 255 ),TEXT_ALIGN_CENTER)
            elseif statusItem[v["ID"]] == 2 then
                draw.RoundedBox(0,0,0, w, h,Color(0,0,50,150))
                draw.DrawText("Unequip","NexaLight25",w/2, 10,Color( 255, 255, 255, 255 ),TEXT_ALIGN_CENTER)
            end
        end

        buyItemSound.DoClick = function()
            if statusItem[v["ID"]] == nil then
                sendNetMessageForTaunt(v["ID"], "BUY")

            elseif statusItem[v["ID"]] == 1 then
                sendNetMessageForTaunt(v["ID"], "EQUIP")

            elseif statusItem[v["ID"]] == 2 then
                sendNetMessageForTaunt(v["ID"], "UNEQUIP")
            end
        end

        local playItemSound = vgui.Create("DButton", itemSound)
        playItemSound:SetPos(660,5)
        playItemSound:SetSize(80,50)
        playItemSound:SetText(" ")
        playItemSound.Paint = function(self, w, h)
            draw.RoundedBox(0,0,0, w, h,Color(50,50,50,150))
            draw.DrawText("Play","NexaLight25",w/2, 10,Color( 255, 255, 255, 255 ),TEXT_ALIGN_CENTER)
        end
        playItemSound.DoClick = function()
            surface.PlaySound(v["Path"])
        end
        newHeight = newHeight+65
    end

    --Partie pointshop
    local pointshopSheet = vgui.Create("DScrollPanel", sheetPanel)
    pointshopSheet.Think = function()
        if _SH_POINTSHOP then
            if _SH_POINTSHOP:IsValid() then
                _SH_POINTSHOP:MoveToFront()
            end
        end
    end

    local pointshopButton = sheetPanel:AddSheet("Pointshop", pointshopSheet, "icon16/basket.png")["Tab"]
    function pointshopButton:GetTabHeight() return 20 end
    function pointshopButton:DoRightClick() return end

    pointshopButton:SetFont("NexaLight25")
    pointshopButton:SetText("             ")
    pointshopButton.Paint = function(self, w, h)
        --draw.RoundedBox(0,0,0, w, h, Color(255,0,0,100))
        draw.DrawText("Pointshop","NexaLight25",28,-3,Color( 255, 255, 255, 255 ),TEXT_ALIGN_LEFT)
    end

    pointshopButton.DoClick = function()
       pointshopButton:GetPropertySheet():SetActiveTab( pointshopButton )
       if _SH_POINTSHOP then
           if _SH_POINTSHOP:IsValid() then
               _SH_POINTSHOP:Close()
           end
       end

       SH_POINTSHOP:OpenMenu()

       if isItMoved then
           CustomizePlyAdjustMenu()
       end
    end

end

net.Receive("MG_SVtoCL_NotifyPlayer",function()
    local argItem = net.ReadString()
    local id = net.ReadInt(11)

    if argItem == "BUY" then
        statusItem[id] = 1

    elseif argItem == "EQUIP" then
        for k, v in pairs(statusItem) do
            if statusItem[k] == 2 then statusItem[k] = 1 end
        end

        statusItem[id] = 2

    elseif argItem == "UNEQUIP" then
        statusItem[id] = 1
    end
end)

net.Receive("MG_SVtoCL_SendInventory", function()
    local inventoryToRead = net.ReadTable()
    local haveItems = inventoryToRead[1]
    local equippedTaunt = tonumber(inventoryToRead[2])

    for k, v in pairs(haveItems) do
        v = tonumber(v)
        statusItem[v] = 1
    end

    if equippedTaunt then statusItem[equippedTaunt] = 2 end

end)
