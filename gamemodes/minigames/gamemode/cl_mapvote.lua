
-- Partie top vote
local topFrame
local timeLeft

local function updateTopVoteFrame()
	local key = Minigames:DefineVoteInfo(MG_WinnerMapGamemode)

	topFrame = vgui.Create("DFrame")
	topFrame:SetSize(ScrW()/3.5-10, 400)
	topFrame:SetPos(5,5)
	topFrame:ShowCloseButton(false)
	topFrame:SetTitle("")
	topFrame.Paint = function()
		draw.RoundedBox(0,0,0,topFrame:GetWide(),topFrame:GetTall(),Color(30,30,30,180))
		draw.DrawText("Top votes", "NexaLight40",topFrame:GetWide()/2, 4, Color(255,255,255), TEXT_ALIGN_CENTER)
	end

	local num = 1
	for k, v in SortedPairsByValue(VoteMapInfo, true) do

		if num > 5 then
			break

		else
			if v > 0 then
				local buttonTopMap = vgui.Create("DButton",topFrame)
				buttonTopMap:SetSize(topFrame:GetWide()-10,50)
				buttonTopMap:SetPos(5, 10+num*60)
				buttonTopMap:SetText("")

				buttonTopMap.Paint = function()
					draw.RoundedBox(0,0,0,buttonTopMap:GetWide(),buttonTopMap:GetTall(),Color(29, 33, 38))
					draw.RoundedBox(0,2,2,buttonTopMap:GetWide()-4,buttonTopMap:GetTall()-4,Color(47, 53, 61))
					draw.DrawText(table.KeyFromValue(key, k) or "nil","NexaLight35", 10, 10, Color( 255, 255, 255, 255 ),TEXT_ALIGN_LEFT)
					draw.DrawText(v,"NexaLight35", buttonTopMap:GetWide()-10, 10, Color( 255, 255, 255, 255 ),TEXT_ALIGN_RIGHT)
				end

				buttonTopMap.DoClick = function()
					if timeLeft > 0 then
						net.Start("Minigames_SendMap")
							net.WriteString(k)
						net.SendToServer()
					end
				end
			end
		end

		num = num + 1
	end
end


net.Receive("Minigames_MapVote", function()
	chat.AddText(Color(242,99,91), "[MINIGAMES] ", Color(255,255,255), "We have reached the round limit! Mapvote is starting...")

	timer.Simple(0.1, function()
		Minigames:Mapvote()
	end)
end)

net.Receive("Minigames_MapVote_SbtC", function()
	local voter_tbl = net.ReadTable()

	Minigames.Gamemodes[voter_tbl[1]] = Minigames.Gamemodes[voter_tbl[1]] + 1

	if voter_tbl[2] then
		Minigames.Gamemodes[voter_tbl[2]] = Minigames.Gamemodes[voter_tbl[2]] - 1
	end
end)

net.Receive("Minigames_SendVotesPerMap", function()
	local voter_tbl = net.ReadTable()

	VoteMapInfo[voter_tbl[1]] = VoteMapInfo[voter_tbl[1]] + 1

	if voter_tbl[2] then
		VoteMapInfo[voter_tbl[2]] = VoteMapInfo[voter_tbl[2]] - 1
	end

	if topFrame then
		topFrame:Remove()
		updateTopVoteFrame()
	else
		updateTopVoteFrame()
	end
end)

net.Receive("Minigames_SendWinningMap",function()
	MG_WinnerMapGamemode = net.ReadString()
end)


net.Receive("Minigames_MapChoice", function()
	local limitTimeVoteMap = CurTime() + Minigames.Map_Timer


	Minigames:CloseMapvote()
	VoteMapInfo = {}

	MG_WinnerMapGamemode = net.ReadString()
	MG_mapsForVote = net.ReadTable()

	local scaleHeightMap = math.floor(#MG_mapsForVote/5, 0)

	for k, v in pairs(MG_mapsForVote) do
		VoteMapInfo[v] = 0
	end

	local framesize = 128*8+60
	local frameheight = 35+10+scaleHeightMap*(128+55)
	// local frameheight = 35+10+128+10+35+10+128+35+20

	local key = Minigames:DefineVoteInfo(MG_WinnerMapGamemode)

	local frame = vgui.Create("DFrame")
	frame:SetSize(ScrW()-(ScrW()/3.5), ScrH()-10)
	frame:SetPos(ScrW()/3.5, 5)
	frame:ShowCloseButton(false)
	frame:SetTitle("")
	frame.Paint = function()
		timeLeft = limitTimeVoteMap - CurTime()
		local colorText

		if timeLeft < 5 then
			colorText = Color(220,0,0)
		else
			colorText = Color(255,255,255)
		end

		if timeLeft < 0 then timeLeft = 0 end

		draw.RoundedBox(0,0,0,frame:GetWide(),frame:GetTall(),Color(30,30,30,180))
		draw.DrawText(MG_WinnerMapGamemode .. " won!", "NexaLight40", frame:GetWide()/2, 4, Color(255, 255, 255, 255),TEXT_ALIGN_CENTER)
		draw.DrawText(string.format("%.2f", math.Round(timeLeft,2)) .. " s", "NexaLight40", 18, 4, colorText, TEXT_ALIGN_LEFT)
	end

	frame.Think = function()
		gui.EnableScreenClicker(true)
	end


	local num = 0
	local line = 0

	local scroll_map = vgui.Create("DScrollPanel", frame)
	scroll_map:SetSize(frame:GetWide()-20,frame:GetTall()-100)
	scroll_map:SetPos(10,70)

	local sbar = scroll_map:GetVBar()
    function sbar:Paint( w, h ) draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 100 ) ) end
    function sbar.btnUp:Paint( w, h ) draw.RoundedBox( 0, 0, 0, w, h, Color( 20, 20, 20, 180 ) ) end
    function sbar.btnDown:Paint( w, h ) draw.RoundedBox( 0, 0, 0, w, h, Color( 20, 20, 20, 180 ) ) end
    function sbar.btnGrip:Paint( w, h ) draw.RoundedBox( 0, 0, 0, w, h, Color( 80, 80, 80, 180) ) end


	local pos = scroll_map:GetWide()-10
	if Minigames.DLC then
		pos = scroll_map:GetWide()-20
	end


	--Cest ici ou les maps sont affiches
	for k, v in pairs(MG_mapsForVote) do
		local mapicon = vgui.Create("DImage", scroll_map)
		mapicon:SetSize(128,128)
		mapicon:SetPos(8+num*138, -40+35+10+line*(128+45+10))

		-- Votes maps
		local rectForNbVote = vgui.Create("DPanel",scroll_map)
		rectForNbVote:SetPos(8+num*138, -40+30+line*(128+45+10)+32-17)
		rectForNbVote:SetSize(32,32)
		rectForNbVote.Paint = function()
			if(VoteMapInfo[v] != 0) then
				draw.RoundedBox(0,0,0,rectForNbVote:GetWide(), rectForNbVote:GetTall(), Color(47,53,61,255))
				draw.DrawText(VoteMapInfo[v], "NexaLight25", 16, 4, Color(255,0,0), TEXT_ALIGN_CENTER)
			end
		end

		local check = file.Exists("materials/niandralades/minigames/mapicons/" .. v ..".png", "GAME")
		if check then
			mapicon:SetImage("materials/niandralades/minigames/mapicons/" .. v ..".png")
		else
			mapicon:SetImage("materials/niandralades/minigames/missing_map.png")
		end

		local mapbutton = vgui.Create("DButton",scroll_map)
		mapbutton:SetText(table.KeyFromValue(key, v))
		mapbutton:SizeToContents()
		mapbutton:SetSize(128,35)
		mapbutton:SetColor(Color(255,255,255))
		mapbutton.Paint = function()
			draw.RoundedBox(0,0,0,mapbutton:GetWide(),mapbutton:GetTall(),Color(29, 33, 38))
			draw.RoundedBox(0,2,2,mapbutton:GetWide()-4,mapbutton:GetTall()-4,Color(47, 53, 61))
		end

		mapbutton:SetPos(10+num*138, -40+183+(line*183))
		mapbutton.DoClick = function()
			net.Start("Minigames_SendMap")
				net.WriteString(v)
			net.SendToServer()
		end


		local nbOfMapsPerLines = (math.floor((frame:GetWide()-80)/128))-2

		if num >= nbOfMapsPerLines then
            line = line + 1
            num = 0
        else
            num = num + 1
		end
	end

	updateTopVoteFrame()

end)

function Minigames:Mapvote()
	Minigames.MapvoteOpen = true
	local vote_size = 6
	local scaleHeightGamemodes = 1+9 -- 9 = nbr gamemodes, marche pas avec table.Count(Minigames.Gamemodes)


	local frame = vgui.Create("DFrame")
	frame:SetSize(600, ScrH()/1.2)
	//frame:SetSize(600, 60*scaleHeightGamemodes + 55
	//frame:SetSize(600, 90+vote_size*50+10*vote_size)

	frame:Center()
	frame:ShowCloseButton(false)
	frame:SetTitle("")
	frame.Paint = function()
		draw.RoundedBox(0,0,0,frame:GetWide(),frame:GetTall(),Color(49,49,49,150))
		draw.DrawText("What are we doing next?", "NexaLight40", frame:GetWide()/2, 8, Color(255, 255, 255, 255),TEXT_ALIGN_CENTER)
		draw.DrawText("To vote, please click on a gamemode", "NexaLight25", frame:GetWide()/2, 40, Color(255, 255, 255, 255),TEXT_ALIGN_CENTER)
	end
	frame.Think = function()
		gui.EnableScreenClicker(true)
	end

	local scroll = vgui.Create("DScrollPanel", frame)
	scroll:SetSize(frame:GetWide()-20,frame:GetTall()-100)
	scroll:SetPos(10,90)

	local pos = scroll:GetWide()-10
	if Minigames.DLC then
		pos = scroll:GetWide()-20
	end

	local num = 0
	for k, v in pairs(Minigames.Gamemodes) do

		/*
		if k == Minigames:ReturnGamemodeString() then
			continue
		end
		*/
		-- Le morceau de code au dessus en comm permet au dernier gamemode de ne pas etre jouer, on le vire cest chiant woulah

		gamemode_button = vgui.Create("DButton", scroll)
		gamemode_button:SetText("")
		gamemode_button:SetSize(scroll:GetWide(), 50)
		gamemode_button:SetPos(0, 0+num*60)
		gamemode_button.DoClick = function()
			net.Start("Minigames_MapVote_CtS")
				net.WriteString(k)
			net.SendToServer()
		end
		gamemode_button.Paint = function()
			if IsValid(gamemode_button) then
				draw.RoundedBox(0,0,0,gamemode_button:GetWide(),gamemode_button:GetTall(),Color(29, 33, 38))
				draw.RoundedBox(0,2,2,gamemode_button:GetWide()-4,gamemode_button:GetTall()-4,Color(47, 53, 61))
				draw.DrawText(k, "NexaLight40", 10, 8, Color(255, 255, 255, 255),TEXT_ALIGN_LEFT)
				draw.DrawText(Minigames.Gamemodes[k], "NexaLight40", pos, 8, Color(255, 255, 255, 255),TEXT_ALIGN_RIGHT)
			end
		end
		num = num + 1
	end

	function Minigames:CloseMapvote()
		if frame then
			frame:Remove()
		end
	end
end


Minigames.NotifsOnScreen = 0
/*
net.Receive("MG_VOTENotif", function()
	local user = net.ReadEntity()
	local vote = net.ReadString()
	local previous_vote = net.ReadString()

	if #previous_vote > 0 and vote ~= previous_vote then
		Minigames:VoteNotification(user,previous_vote,false)
	end

	if vote ~= previous_vote then
		Minigames:VoteNotification(user,vote,true)
	end
end)
*/

function Minigames:VoteNotification(user,vote,bool)

	local sign = ""
	if bool then
		sign = "+"
	else
		sign = "-"
	end

	local size = string.len(vote)
	if size >= 17 then
		local calc = size-15
		local right = string.Right(vote,calc)
		local outcome = string.Replace(vote, right, "...")
		local vote = outcome
	end

	local frame = vgui.Create("DFrame")
	frame:SetSize(250, 42)
	frame:SetTitle("")
	frame:ShowCloseButton(false)
	frame:SetPos(ScrW()+250, ScrH()-150-Minigames.NotifsOnScreen*50)
	frame.Paint = function()
		draw.RoundedBox(0,0,0,frame:GetWide(),frame:GetTall(),Color(29, 33, 38))
		draw.RoundedBox(0,2,2,frame:GetWide()-4,frame:GetTall()-4,Color(47, 53, 61))
	end

	frame:MoveTo(ScrW()-250, ScrH()-150-Minigames.NotifsOnScreen*50,0.4,0,2,nil)

	timer.Simple(3, function()
		frame:MoveTo(ScrW()+250, frame.y,0.4,0,2,function()
			Minigames.NotifsOnScreen = Minigames.NotifsOnScreen - 1
			frame:Remove()
		end)
	end)

	local avatar = vgui.Create("AvatarImage", frame)
	avatar:SetPos(frame:GetWide()-5-32, 5)
	avatar:SetSize(32,32)
	avatar:SetPlayer(user, 32)

	local text = vgui.Create("DLabel", frame)
	text:SetText(sign .. "1 " .. vote)
	text:SetFont("NexaLight20")
	text:SizeToContents()
	text:SetPos(5,10)

	Minigames.NotifsOnScreen = Minigames.NotifsOnScreen + 1
end
