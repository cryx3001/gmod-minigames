-- Custom weapon base, used to derive from CS one, still very similar
AddCSLuaFile()
SWEP.ownerWep = nil

if CLIENT then
   SWEP.DrawCrosshair   = false
   SWEP.ViewModelFOV    = 82
   SWEP.ViewModelFlip   = true
   SWEP.CSMuzzleFlashes = true
end

SWEP.Base = "weapon_base_master"

SWEP.Spawnable          = false

SWEP.IsGrenade = false

SWEP.Weight             = 5
SWEP.AutoSwitchTo       = false
SWEP.AutoSwitchFrom     = false

SWEP.Primary.Sound          = Sound( "Weapon_Pistol.Empty" )
SWEP.Primary.Recoil         = 1.5
SWEP.Primary.Damage         = 1
SWEP.Primary.NumShots       = 1
SWEP.Primary.Cone           = 0.02
SWEP.Primary.Delay          = 0.15
SWEP.UseHands = true
SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = false
SWEP.Primary.Ammo           = "none"
SWEP.Primary.ClipMax        = -1

SWEP.Secondary.ClipSize     = 1
SWEP.Secondary.DefaultClip  = 1
SWEP.Secondary.Automatic    = false
SWEP.Secondary.Ammo         = "none"
SWEP.Secondary.ClipMax      = -1

SWEP.StoredAmmo = 0
SWEP.ShouldDropOnDie = true
SWEP.IsDropped = true

SWEP.DeploySpeed = 1.4

SWEP.PrimaryAnim = ACT_VM_PRIMARYATTACK
SWEP.ReloadAnim = ACT_VM_RELOAD

SWEP.isZoomingIronSight = nil
SWEP.isPlyReloading = nil
SWEP.canScopeSniper = true

SWEP.normalSpeedWalk = nil
SWEP.normalSpeedRun = nil
SWEP.newSpeedWalk = nil
SWEP.newSpeedRun = nil

SWEP.originalCone = nil
SWEP.newCone = nil

-- crosshair
if CLIENT then
	SWEP.CrosshairParts = {left = true, right = true, upper = true, lower = true}

	surface.CreateFont( "cssweapon", {
    	font = "csd", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
    	size = 100,
	})

	surface.CreateFont( "NexaLight55plugran", {
    	font = "NexaLight55", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
    	size = 90,
	})

	SWEP.CrossAmount = 0
	SWEP.CrossAlpha = 255
	SWEP.FadeAlpha = 0
	SWEP.CurFOVMod = 0
	SWEP.ZoomAmount = 15
	SWEP.CrosshairParts = {left = true, right = true, upper = true, lower = true}

    local XHairEnabled = CreateClientConVar("crosshair_enabled", 0, true, false)
    local XHairThickness = CreateClientConVar("crosshair_thickness", 1.5, true, false)
    local XHairGap = CreateClientConVar("crosshair_gap", 15, true, false)
    local XHairSize = CreateClientConVar("crosshair_size", 7, true, false)
    local XHairRed = CreateClientConVar("crosshair_red", 0, true, false)
    local XHairGreen = CreateClientConVar("crosshair_green", 255, true, false)
    local XHairBlue = CreateClientConVar("crosshair_blue", 0, true, false)
    local XHairAlpha = CreateClientConVar("crosshair_alpha", 255, true, false)
    local XHairDot = CreateClientConVar("crosshair_dot_size", 1, true, false)


    local function DrawCrosshair( x, y )
    	y = y-1
    	local thick = XHairThickness:GetInt()
    	local gap = XHairGap:GetInt()
    	local size = XHairSize:GetInt()
    	local dotsize = XHairDot:GetInt()

    	surface.SetDrawColor(XHairRed:GetInt(), XHairGreen:GetInt(), XHairBlue:GetInt(), XHairAlpha:GetInt())
    	surface.DrawRect(x - (thick/2), y - (size + gap/2), thick, size )
    	surface.DrawRect(x - (thick/2), y + (gap/2), thick, size )
    	surface.DrawRect(x + (gap/2), y - (thick/2), size, thick )
    	surface.DrawRect(x - (size + gap/2), y - (thick/2), size, thick )
    	if dotsize then
    		surface.DrawRect(x - (dotsize/2), y - (dotsize/2), dotsize, dotsize)
    	end
    end


    function SWEP:DrawHUD()
        local weps = {
            ["weapon_ak47"] = "b",
            ["weapon_aug"] = "e",
            ["weapon_awp"] = "r",
            ["weapon_csfrag"] = "O",
            ["weapon_deagle"] = "f",
            ["weapon_elite"] = "s",
            ["weapon_famas"] = "t",
            ["weapon_fiveseven"] = "u",
            ["weapon_g3sg1"] = "i",
            ["weapon_galil"] = "v",
            ["weapon_glock"] = "c",
            ["weapon_knife"] = "j",
            ["weapon_m3"] = "k",
            ["weapon_m4a1"] = "w",
            ["weapon_m249"] = "z",
            ["weapon_mac10"] = "l",
            ["weapon_mp5"] = "x",
            ["weapon_p90"] = "m",
            ["weapon_p228"] = "a",
            ["weapon_scout"] = "n",
            ["weapon_sg550"] = "o",
            ["weapon_sg552"] = "A",
            ["weapon_smoke"] = "",
            ["weapon_tmp"] = "d",
            ["weapon_ump45"] = "P",
            ["weapon_usp"] = "y",
            ["weapon_xm1014"] = "B",
        }

        if (not Minigames.ScoreboardOpen or not Minigames.MapvoteOpen) and not Minigames:IsPlayingOITC() then
            surface.SetDrawColor(Color(255,255,255,255))
    		--surface.SetMaterial(mat)
    		--surface.DrawTexturedRect(20, ScrH()-32-64-32-38,32,32)
            local m=250

    		if self:Clip1()!=-1 then
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

        		draw.DrawText(self:Clip1(), "NexaLight55", ScrW()-215, ScrH()-100, Color(255,255,255, 255),TEXT_ALIGN_LEFT)
        		draw.DrawText(self:Ammo1(), "NexaLight40", ScrW()-50, ScrH()-85, Color(255,255,255, 255),TEXT_ALIGN_RIGHT)
            end

            draw.SimpleTextOutlined(string.upper(self:GetPrintName()), "NexaLight35", ScrW()-215, ScrH()-130, Color(255,255,255, 255),TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP , 1 , Color(0,0,0))
        end


		FT, CT, x, y = FrameTime(), CurTime(), ScrW(), ScrH()
		UCT = UnPredictedCurTime()

        if (self.ForceCrosshair or (not self:GetNWBool("Ironsights"))) and !(self.PrintName == "Awp" or self.PrintName == "Scout") and GetConVar( "simple_thirdperson_enabled" ):GetBool() == false then --self.ForceCrosshair or (self.IronsightsAim and self.dt.State == SWB_AIMING) then
            local wep = LocalPlayer():GetActiveWeapon()

            if XHairEnabled:GetInt() == 1 and IsValid(wep) and !wep.NoCross then
                DrawCrosshair( ScrW()/2 + 1, ScrH()/2 + 2)
            end
        end
	end
end

function SWEP:GetHeadshotMultiplier(victim, dmginfo)
	return self.HeadshotMultiplier
end

function SWEP:RestoreValue(owner)
    self.isZoomingIronSight = false

    owner:SetFOV( 0, 0.3 )
    self.DrawCrosshair = self.OrigCrossHair

    self.Primary.Cone = self.newCone

    if self.normalSpeedWalk and self.normalSpeedRun then
        owner:SetWalkSpeed(self.normalSpeedWalk)
        owner:SetRunSpeed(self.normalSpeedRun)
    end

    self:SetIronsights(false, owner)
    -- //Set the ironsight false

    if CLIENT then self.DrawCrosshair = self.OrigCrossHair end
end

-- Shooting functions largely copied from weapon_cs_base
function SWEP:PrimaryAttack(worldsnd)

	self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

	if not self:CanPrimaryAttack() then return end

	if not worldsnd then
		self:EmitSound( self.Primary.Sound, self.Primary.SoundLevel )
	elseif SERVER then
		sound.Play(self.Primary.Sound, self:GetPos(), self.Primary.SoundLevel)
	end

	self:ShootBullet( self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self:GetPrimaryCone() )

	self:TakePrimaryAmmo( 1 )

    if(SERVER) then self.Owner.STATS_shotsFired = self.Owner.STATS_shotsFired + 1 end

	local owner = self:GetOwner()
	if not IsValid(owner) or owner:IsNPC() or (not owner.ViewPunch) then return end

	owner:ViewPunch( Angle( util.SharedRandom(self:GetClass(),-0.2,-0.1,0) * self.Primary.Recoil, util.SharedRandom(self:GetClass(),-0.1,0.1,1) * self.Primary.Recoil, 0 ) )
	self.NextFireTime = CurTime() + self.Primary.Delay

	if self.PrintName == "Awp" or self.PrintName == "Scout" then
		self.canScopeSniper = false
		timer.Simple(1.5, function()
			self.canScopeSniper = true
		end)
	end
end

function SWEP:DryFire(setnext)
   if CLIENT and LocalPlayer() == self:GetOwner() then
      self:EmitSound( "Weapon_Pistol.Empty" )
   end

   setnext(self, CurTime() + 0.2)

end

function SWEP:CanPrimaryAttack()
   if not IsValid(self:GetOwner()) then return end

   if self:Clip1() <= 0 then
      self:DryFire(self.SetNextPrimaryFire)
      return false
   end
   return true
end

function SWEP:CanSecondaryAttack()
   if not IsValid(self:GetOwner()) then return end

   if self:Clip2() <= 0 then
      self:DryFire(self.SetNextSecondaryFire)
      return false
   end
   return true
end


function SWEP:ShootBullet( dmg, recoil, numbul, cone )

   self:SendWeaponAnim(self.PrimaryAnim)

   self:GetOwner():MuzzleFlash()
   self:GetOwner():SetAnimation( PLAYER_ATTACK1 )

   local sights = self:GetIronsights()

   numbul = numbul or 1
   cone   = cone   or 0.01

   local bullet = {}
   bullet.Num    = numbul
   bullet.Src    = self:GetOwner():GetShootPos()
   bullet.Dir    = self:GetOwner():GetAimVector()
   bullet.Spread = Vector( cone, cone, 0 )
   bullet.Tracer = 4
   bullet.TracerName = self.Tracer or "Tracer"
   bullet.Force  = 10
   bullet.Damage = dmg

   self:GetOwner():FireBullets( bullet )

	if SERVER then
		local dmgInfo = DamageInfo()

		dmgInfo:SetDamage(dmg)
		dmgInfo:SetAttacker(self.Owner)
		dmgInfo:SetInflictor(self.Weapon or self)
	end

   -- Owner can die after firebullets
   if (not IsValid(self:GetOwner())) or (not self:GetOwner():Alive()) or self:GetOwner():IsNPC() then return end

   if ((game.SinglePlayer() and SERVER) or
       ((not game.SinglePlayer()) and CLIENT and IsFirstTimePredicted())) then

      -- reduce recoil if ironsighting
      recoil = sights and (recoil * 0.6) or recoil

      local eyeang = self:GetOwner():EyeAngles()
      eyeang.pitch = eyeang.pitch - recoil
      self:GetOwner():SetEyeAngles( eyeang )
   end
end

function SWEP:GetPrimaryCone()
   local cone = self.Primary.Cone or 0.2
   -- 10% accuracy bonus when sighting
   return self:GetIronsights() and (cone * 0.85) or cone
end

function SWEP:DrawWeaponSelection() end

function SWEP:SecondaryAttack()
   if self.NoSights or (not self.IronSightsPos) then return end

   self:SetNextSecondaryFire(CurTime() + 0.3)
end

function SWEP:Deploy()
   self:SetIronsights(false, self.Owner)
   return true
end

function SWEP:Reload()
	if ( self:Clip1() == self.Primary.ClipSize or self:GetOwner():GetAmmoCount( self.Primary.Ammo ) <= 0 ) then return end
	if self.isZoomingIronSight then return end

	self:DefaultReload(self.ReloadAnim)
	self:SetIronsights(false)
end

hook.Add("DoCustomAnimEvent", "Hook_AnimIsPlyReloading", function(ply , event , data)
	if event == 3 or event == 4 or event == 0 then
		self.isPlyReloading = true
	else
		self.isPlyReloading = false
	end
end)

function SWEP:OnRestore()
   self.NextSecondaryAttack = 0
   self:SetIronsights( false )
end

function SWEP:Ammo1()
	return self.Owner:GetAmmoCount( self.Weapon:GetPrimaryAmmoType() )
end

function SWEP:PreDrop()
   if SERVER and IsValid(self:GetOwner()) and self.Primary.Ammo != "none" then
      local ammo = self:Ammo1()

      -- Do not drop ammo if we have another gun that uses this type
      for _, w in pairs(self:GetOwner():GetWeapons()) do
         if IsValid(w) and w != self and w:GetPrimaryAmmoType() == self:GetPrimaryAmmoType() then
            ammo = 0
         end
      end

      self.StoredAmmo = ammo

      if ammo > 0 then
         self:GetOwner():RemoveAmmo(ammo, self.Primary.Ammo)
      end
   end
end

function SWEP:DampenDrop()
   -- For some reason gmod drops guns on death at a speed of 400 units, which
   -- catapults them away from the body. Here we want people to actually be able
   -- to find a given corpse's weapon, so we override the velocity here and call
   -- this when dropping guns on death.
   local phys = self:GetPhysicsObject()
   if IsValid(phys) then
      phys:SetVelocityInstantaneous(Vector(0,0,-5))
   end
end

local SF_WEAPON_START_CONSTRAINED = 1

-- Picked up by player. Transfer of stored ammo and such.
function SWEP:Equip(newowner)

   if SERVER then
      if self:IsOnFire() then
         self:Extinguish()
      end

      if self:HasSpawnFlags(SF_WEAPON_START_CONSTRAINED) then
         -- If this weapon started constrained, unset that spawnflag, or the
         -- weapon will be re-constrained and float
         local flags = self:GetSpawnFlags()
         local newflags = bit.band(flags, bit.bnot(SF_WEAPON_START_CONSTRAINED))
         self:SetKeyValue("spawnflags", newflags)
      end
   end

   if SERVER and IsValid(newowner) and self.StoredAmmo > 0 and self.Primary.Ammo != "none" then
      local ammo = newowner:GetAmmoCount(self.Primary.Ammo)
      local given = math.min(self.StoredAmmo, self.Primary.ClipMax - ammo)
	  newowner:GiveAmmo( 200, self.Primary.Ammo)
      newowner:GiveAmmo( given, self.Primary.Ammo)
      self.StoredAmmo = 0
   end

   if IsValid(newowner) then
       self.ownerWep = newowner
   end
end

function SWEP:SetIronsights( b )

	self.Weapon:SetNetworkedBool( "Ironsights", b )

end

function SWEP:GetIronsights()
	return self.Weapon:GetNWBool("Ironsights")
end

--- Dummy functions that will be replaced when SetupDataTables runs. These are
--- here for when that does not happen (due to e.g. stacking base classes)
function SWEP:GetIronsightsTime() return -1 end
function SWEP:SetIronsightsTime() end
function SWEP:GetIronsightsPredicted() return false end
function SWEP:SetIronsightsPredicted() end

-- Set up ironsights dt bool. Weapons using their own DT vars will have to make
-- sure they call this.
function SWEP:SetupDataTables()
   self:NetworkVar("Bool", 3, "IronsightsPredicted")
   self:NetworkVar("Float", 3, "IronsightsTime")
end

function SWEP:Initialize()
   if CLIENT and self:Clip1() == -1 then
      self:SetClip1(self.Primary.DefaultClip)
	  if IsValid(self:GetOwner()) and self.Primary.DefaultClip and self.Weapon:GetPrimaryAmmoType()  then
          self:GetOwner():GiveAmmo( self.Primary.DefaultClip, self.Weapon:GetPrimaryAmmoType() )
      end
   elseif SERVER then

      self:SetIronsights(false)
   end

   self:SetDeploySpeed(self.DeploySpeed)

   -- compat for gmod update
   if self.SetHoldType then
      self:SetHoldType(self.HoldType or "pistol")
   end
   self.NextFireTime = 0

   self.originalCone = self.Primary.Cone
   self.newCone = self.originalCone + 0.16

end


-- Note that if you override Think in your SWEP, you should call
-- BaseClass.Think(self) so as not to break ironsights
function SWEP:Think()
    self:IronSight()
end


local IRONSIGHT_TIME = 0.25
function SWEP:GetViewModelPosition( pos, ang )

	if ( !self.IronSightsPos ) then return pos, ang end

	local bIron = self.Weapon:GetNetworkedBool( "Ironsights" )

	if ( bIron != self.bLastIron ) then

		self.bLastIron = bIron
		self.fIronTime = CurTime()

		if ( bIron ) then
			self.SwayScale 	= 0.3
			self.BobScale 	= 0.1
		else
			self.SwayScale 	= 1.0
			self.BobScale 	= 1.0
		end

	end

	local fIronTime = self.fIronTime or 0

	if ( !bIron && fIronTime < CurTime() - IRONSIGHT_TIME ) then
		return pos, ang
	end

	local Mul = 1.0

	if ( fIronTime > CurTime() - IRONSIGHT_TIME ) then

		Mul = math.Clamp( (CurTime() - fIronTime) / IRONSIGHT_TIME, 0, 1 )

		if (!bIron) then Mul = 1 - Mul end

	end

	local Offset	= self.IronSightsPos

	if ( self.IronSightsAng ) then

		ang = ang * 1
		ang:RotateAroundAxis( ang:Right(), 		self.IronSightsAng.x * Mul )
		ang:RotateAroundAxis( ang:Up(), 		self.IronSightsAng.y * Mul )
		ang:RotateAroundAxis( ang:Forward(), 	self.IronSightsAng.z * Mul )


	end

	local Right 	= ang:Right()
	local Up 		= ang:Up()
	local Forward 	= ang:Forward()



	pos = pos + Offset.x * Right * Mul
	pos = pos + Offset.y * Forward * Mul
	pos = pos + Offset.z * Up * Mul

	return pos, ang

end

function SWEP:IronSight()
	self.Secondary.IronFOV = self.Secondary.IronFOV or 0

	if not IsValid(self) then
		self.Owner:SetFOV(0,0.3)
		return
	end

	if not IsValid(self.Owner) then
		self.Owner:SetFOV(0,0.3)
		return
	end


    if !self.isZoomingIronSight and self.Owner:GetWalkSpeed() and self.Owner:GetRunSpeed()  then
        self.normalSpeedWalk = self.Owner:GetWalkSpeed()
        self.normalSpeedRun = self.Owner:GetRunSpeed()

        self.newSpeedWalk = self.normalSpeedWalk / 2.5
        self.newSpeedRun = self.normalSpeedRun / 2.5
    end

	if !self.Owner:IsNPC() then
    	if self.ResetSights and CurTime() >= self.ResetSights then
        	self.ResetSights = nil

        	if self.Silenced then
        			self:SendWeaponAnim(ACT_VM_IDLE_SILENCED)
        	else
        			self:SendWeaponAnim(ACT_VM_IDLE)
        	end
    	end
    end


	if self.CanBeSilenced and self.NextSilence < CurTime() then
		if self.Owner:KeyDown(IN_USE) and self.Owner:KeyPressed(IN_ATTACK2) then
	        self:Silencer()
		end
	end

	if self.SelectiveFire and self.NextFireSelect < CurTime() and not (self.Weapon:GetNWBool("Reloading")) then
		if self.Owner:KeyDown(IN_USE) and self.Owner:KeyPressed(IN_RELOAD) then
	        self:SelectFireMode()
		end
	end

	if !self.Owner:KeyDown(IN_USE) then
	-- //If the key E (Use Key) is not pressed, then

		if !self.Owner:KeyDown(IN_ATTACK) and self.Owner:KeyPressed(IN_ATTACK2) and (self.PrintName == "Awp" or self.PrintName == "Sg550" or  self.PrintName == "Sg552" or self.PrintName == "Aug" or self.PrintName == "Scout" or self.PrintName == "G3SG-1") and !self.isPlyReloading and self.canScopeSniper then
            self.isZoomingIronSight = true

            self.Owner:SetFOV( self.Secondary.IronFOV, 0.3 )
			self.IronSightsPos = self.SightsPos                                     -- Bring it up
			self.IronSightsAng = self.SightsAng                                     -- Bring it up

            self.Owner:SetWalkSpeed(self.newSpeedWalk)
            self.Owner:SetRunSpeed(self.newSpeedRun)

			self:SetIronsights(true, self.Owner)
		end
	end

	if (self.Owner:KeyReleased(IN_ATTACK2) and !self.Owner:KeyDown(IN_USE)) then

		self.isZoomingIronSight = false

           -- //If the right click is released, then
		self.Owner:SetFOV( 0, 0.3 )
		self.DrawCrosshair = self.OrigCrossHair

        self.Primary.Cone = self.newCone

        if self.normalSpeedWalk and self.normalSpeedRun then
            self.Owner:SetWalkSpeed(self.normalSpeedWalk)
            self.Owner:SetRunSpeed(self.normalSpeedRun)
        end

		self:SetIronsights(false, self.Owner)
		-- //Set the ironsight false

		if CLIENT then self.DrawCrosshair = self.OrigCrossHair end
	end

	if !self.Owner:KeyDown(IN_ATTACK) and self.Owner:KeyDown(IN_ATTACK2) and !self.Owner:KeyDown(IN_USE) and (self.PrintName == "Awp" or self.PrintName == "Sg550" or  self.PrintName == "Sg552" or self.PrintName == "Aug" or self.PrintName == "Scout" or self.PrintName == "G3SG-1") and !self.isPlyReloading and self.canScopeSniper then
		self.isZoomingIronSight = true

        if self.normalSpeedWalk and self.normalSpeedRun then
            self.Owner:SetWalkSpeed(self.newSpeedWalk)
            self.Owner:SetRunSpeed(self.newSpeedRun)
        end

		self.SwayScale  = 0.05
		self.BobScale   = 0.05
	else
		self.SwayScale  = 1.0
		self.BobScale   = 1.0
	end

    if self.isZoomingIronSight and (self.PrintName == "Awp" or self.PrintName == "Sg550" or  self.PrintName == "Sg552" or self.PrintName == "Aug" or self.PrintName == "Scout" or self.PrintName == "G3SG-1") then
        self.Primary.Cone = self.originalCone
    elseif !(self.PrintName == "Awp" or self.PrintName == "Sg550" or  self.PrintName == "Sg552" or self.PrintName == "Aug" or self.PrintName == "Scout" or self.PrintName == "G3SG-1") then
        self.Primary.Cone = self.originalCone
    else
        self.Primary.Cone = self.newCone
    end

end

function SWEP:OnRemove()
    if !IsValid(self.ownerWep) then return end
    self:RestoreValue(self.ownerWep)
    self.ownerWep = nil
end

function SWEP:OnDrop()
    self:RestoreValue(self.ownerWep)
    self.ownerWep = nil
end
