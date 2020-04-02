AddCSLuaFile()

SWEP.Base 							= "weapon_mgbase"
SWEP.EntName						= ""
SWEP.HoldReady						= "grenade"
SWEP.HoldNormal						= "slam"
SWEP.DetonateTime					= 5
SWEP.Magnitude						= 1
SWEP.Radius							= 1
SWEP.Category						= "Grenade"
SWEP.Slot 							= 3
SWEP.ViewModelFOV   				= 70

SWEP.Secondary.MaxDistance			= 1

SWEP.Primary.ClipSize				= -1
SWEP.Primary.DefaultClip			= -1
SWEP.Primary.Automatic				= false
SWEP.Primary.Ammo					= "none"
SWEP.Primary.Delay					= 1
SWEP.Primary.MaxDistance			= 1

SWEP.Secondary.ClipSize				= -1
SWEP.Secondary.DefaultClip			= -1
SWEP.Secondary.Automatic			= false
SWEP.Secondary.Ammo					= "none"
SWEP.Secondary.Delay				= 1
SWEP.Secondary.MaxDistance			= 1

SWEP.pulledTime = 0

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "Pin")
	self:NetworkVar("Int", 0, "ThrowTime")
	self:NetworkVar("Int", 1, "DetonateTime")
	self:NetworkVar("Int", 2, "Distance")
end

function SWEP:CanPrimaryAttack() return true end
function SWEP:CanSecondaryAttack() return true end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end

	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)

	self:SetDistance(self.Primary.Distance)

	self:PullPin()
end

function SWEP:SecondaryAttack()
	if !self:CanSecondaryAttack() then return end

	self:SetNextPrimaryFire(CurTime() + self.Secondary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)

	self:SetDistance(self.Secondary.Distance)

	self:PullPin()
end

function SWEP:PullPin()
	if self:GetPin() then return end

	self:SendWeaponAnim(ACT_VM_PULLPIN)

	if self.SetHoldType then
		self:SetHoldType(self.HoldReady)
	end

	self:SetPin(true)

	self:SetDetonateTime(CurTime() + self.DetonateTime)
	self.pulledTime = CurTime()
end

function SWEP:OnExplodeInHands() end

function SWEP:Think()
	if !IsValid(self.Owner) then return end

	if self:GetPin() then
		if !self.Owner:KeyDown(IN_ATTACK) and !self.Owner:KeyDown(IN_ATTACK2) then
			self:StartThrow()

			self:SetPin(false)
			self:SendWeaponAnim(ACT_VM_THROW)

			self.Owner:SetAnimation(PLAYER_ATTACK1)
		else
			if self:GetDetonateTime() < CurTime() then
				if SERVER then
					local gren = ents.Create(self.EntName)

					if !IsValid(gren) then return end

					gren:SetPos(self.Owner:GetPos())
					gren:SetOwner(self.Owner)

					gren:Spawn()
					gren:SetNoDraw(true)

					gren:SetExplodeTime(CurTime())
					gren:SetExplodedInHands(true)

					self:Remove()
				end

				if !self.exploded then
					self.OnExplodeInHands(self)
				end

				self.exploded = true
			end
		end
	elseif self:GetThrowTime() > 0 and self:GetThrowTime() < CurTime() then
		self:Throw()
	end
end

function SWEP:StartThrow()
	self:SetThrowTime(CurTime() + 0.1)
end

function SWEP:Throw()
	self:SetThrowTime(0)

	if SERVER then
		local ply = self.Owner
		if !IsValid(ply) then return end

		local ang = ply:EyeAngles()
		local src = ply:GetPos() + (ply:Crouching() and ply:GetViewOffsetDucked() or ply:GetViewOffset()) + ang:Forward() * 8 + ang:Right() * 10
		local target = ply:GetEyeTraceNoCursor().HitPos
		local tang = (target - src):Angle()

		tang.p = tang.p - 0.1

		local vel = self:GetDistance()
		local thr = tang:Forward() * vel + ply:GetVelocity()

		self:CreateGrenade(src, thr, Vector(600, math.random(-1200, 1200), 0), ply)

		self:Remove()
	end
end

function SWEP:CreateGrenade(src, vel, angimp, ply)
	local gren = ents.Create(self.EntName)
	if !IsValid(gren) then return end

	gren:SetPos(src)
	gren:SetOwner(ply)

	gren:SetGravity(0)

	gren:Spawn()

	gren:PhysWake()

	local phys = gren:GetPhysicsObject()

	if IsValid(phys) then
		phys:SetVelocity(vel)
		phys:AddAngleVelocity(angimp)
	end

	gren:SetExplodeTime(self.pulledTime + self.DetonateTime)

	return gren
end

function SWEP:DrawHUD()
	if not Minigames.ScoreboardOpen or not Minigames.MapvoteOpen then
		surface.SetDrawColor(Color(255,255,255,255))
		--surface.SetMaterial(mat)
		--surface.DrawTexturedRect(20, ScrH()-32-64-32-38,32,32)
		local m=250
		local p = 100
		local o = 180
		local h = 90
		local i = 0  -- Valeur pour déterminer la valeur de la fenetre ( si i + n ==> descend la fenetre)
		local k = 2

		surface.SetDrawColor(0,0,0,150)
		surface.DrawRect(ScrW()-220,ScrH()-20-20-80-30+20,o,h)

		surface.SetDrawColor(0,0,0)
		surface.DrawOutlinedRect(ScrW()-220  ,ScrH()-20-20-80-30+20,o,h)
		surface.DrawOutlinedRect(ScrW()-220-1,ScrH()-20-20-80-30+20-1,o + 1,h + 1)
		surface.DrawOutlinedRect(ScrW()-220-2,ScrH()-20-20-80-30+20-2,o + 3,h + 3)
		surface.DrawOutlinedRect(ScrW()-220-2,ScrH()-20-20-80-30+20-2,o + 4,h + 4)

		local timeToShow
		local colorTextGrenade
		if (self:GetDetonateTime() - CurTime()) < 0 then
			timeToShow = self.DetonateTime
		else
			timeToShow = self:GetDetonateTime() - CurTime()
		end

		if timeToShow < self.DetonateTime and timeToShow > 2 then
			colorTextGrenade = Color(240,100,0)
		elseif timeToShow < 2 then
			colorTextGrenade = Color(240,0,0)
		else
			colorTextGrenade = Color(240,240,240)
		end

		draw.DrawText(string.format("%.2f", math.Round(timeToShow,2)) .. " s" , "NexaLight55", ScrW()-50, ScrH()-100, colorTextGrenade,TEXT_ALIGN_RIGHT)

		draw.SimpleTextOutlined(string.upper(self:GetPrintName()), "NexaLight35", ScrW()-215, ScrH()-130, Color(255,255,255, 255),TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP , 1 , Color(0,0,0))
	end
end

function SWEP:PreDrop()
	if self:GetPin() then
		self:SetDistance(120)
		self:Throw()

		return false
	end
end

function SWEP:Deploy()
	if self.SetHoldType then
		self:SetHoldType(self.HoldNormal)
	end

	self:SetThrowTime(0)
	self:SetPin(false)

	local vm = self.Owner:GetViewModel()

	if IsValid(vm) then
		vm:SetModel(self.ViewModel)
	end

	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
end

function SWEP:Holster()
	if self:GetPin() then
		return false
	end

	self:SetThrowTime(0)
	self:SetPin(false)

	return true
end

function SWEP:Initialize()
	if self.SetHoldType then
		self:SetHoldType(self.HoldNormal)
	end

	self:SetDeploySpeed(self.DeploySpeed)

	self:SetDetonateTime(3)
	self:SetThrowTime(0)
	self:SetPin(false)
end

function SWEP:Reload() end

function SWEP:Equip() end
