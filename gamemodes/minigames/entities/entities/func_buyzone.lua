ENT.Type = "brush"

function ENT:Initialize()
	self:SetTrigger( true )
end

function ENT:Think()
end

function ENT:StartTouch(ent)
	if ent:IsPlayer() and ent:IsValid() and Minigames.RoundState == 1 and !(Minigames:IsPlayingOITC() or Minigames:IsPlayingGunGame() or Minigames:IsPlayingFreeForAll() or Minigames:IsPlayingTwoVersusAll() or Minigames:IsPlayingAssaultCourse()) then
		ent.CanBuy = self
		ent:SendLua("CanBuy="..self:EntIndex())
	end

	if #player.GetAll() == 1 then
		ent.CanBuy = nil
		if ent:IsValid() and ent:IsPlayer() then ent:SendLua("CanBuy=nil") end
	end
end

function ENT:EndTouch(ent)
	if ent.CanBuy == self then
		ent.CanBuy = nil
		ent:SendLua("CanBuy=nil")
	end
end

function ENT:Touch(ent)
	if Minigames.RoundState == 2 then
		ent.CanBuy = nil
		if ent:IsValid() and ent:IsPlayer() then ent:SendLua("CanBuy=nil") end
	end
end
