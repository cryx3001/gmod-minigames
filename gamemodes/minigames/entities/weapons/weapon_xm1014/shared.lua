SWEP.Secondary.IronFOV			= 55
SWEP.Primary.Recoil = 0.5
SWEP.Primary.NumShots = 6
SWEP.Primary.Cone = 0.08

AddCSLuaFile( "shared.lua" )

SWEP.PrintName			= "XM1014"
SWEP.Slot				= 0
SWEP.SlotPos			= 1

SWEP.ViewModelFOV		= 57
SWEP.ViewModelFlip		= false

SWEP.HoldType			= "shotgun"
SWEP.Base				= "weapon_base_mg"
SWEP.Category			= "Primary"

//Primary
SWEP.Primary.Automatic		= true
SWEP.Primary.Sound 			= Sound( "Weapon_XM1014.Single" )
SWEP.Primary.Recoil = 2
SWEP.Primary.NumShots = 8
SWEP.Primary.Cone = 0.10
SWEP.HeadshotMultiplier     = 2
SWEP.Primary.Damage = 9
SWEP.Primary.Delay = 0.5
SWEP.Primary.ClipSize = 8
SWEP.Primary.DefaultClip = 420
SWEP.Shotgun = true
SWEP.Shots = 6
SWEP.ClumpSpread = 0.04
SWEP.Primary.Ammo           = "Pistol"


SWEP.Spawnable			= false
SWEP.AdminSpawnable		= true

SWEP.ViewModel		= "models/weapons/cstrike/c_shot_xm1014.mdl"
SWEP.WorldModel			= "models/weapons/w_shot_xm1014.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.IronSightsPos = Vector(-6.96, -4.16, 2.707)
SWEP.IronSightsAng = Vector(-0.139, -0.803, 0)
SWEP.SightsPos = Vector(-6.96, -4.16, 2.707)
SWEP.SightsAng = Vector(-0.139, -0.803, 0)
SWEP.RunSightsPos = Vector(5.748, -13.78, 4.015)
SWEP.RunSightsAng = Vector(-20.67, 46.023, 0)
SWEP.Secondary.IronFOV			= 55

SWEP.reloadtimer = 0


function SWEP:SetupDataTables()
   self:DTVar("Bool", 0, "reloading")

   return self.BaseClass.SetupDataTables(self)
end

function SWEP:Reload()
   self:SetIronsights( false )

   --if self.Weapon:GetNetworkedBool( "reloading", false ) then return end
   if self.dt.reloading then return end

   if not IsFirstTimePredicted() then return end

   if self.Weapon:Clip1() < self.Primary.ClipSize and self.Owner:GetAmmoCount( self.Primary.Ammo ) > 0 then

      if self:StartReload() then
         return
      end
   end

end

function SWEP:StartReload()
   --if self.Weapon:GetNWBool( "reloading", false ) then
   if self.dt.reloading then
      return false
   end

   if not IsFirstTimePredicted() then return false end

   self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

   local ply = self.Owner

   if not ply or ply:GetAmmoCount(self.Primary.Ammo) <= 0 then
      return false
   end

   local wep = self.Weapon

   if wep:Clip1() >= self.Primary.ClipSize then
      return false
   end

   wep:SendWeaponAnim(ACT_SHOTGUN_RELOAD_START)

   self.reloadtimer =  CurTime() + wep:SequenceDuration()

   --wep:SetNWBool("reloading", true)
   self.dt.reloading = true

   return true
end

function SWEP:PerformReload()
   local ply = self.Owner

   -- prevent normal shooting in between reloads
   self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

   if not ply or ply:GetAmmoCount(self.Primary.Ammo) <= 0 then return end

   local wep = self.Weapon

   if wep:Clip1() >= self.Primary.ClipSize then return end

   self.Owner:RemoveAmmo( 1, self.Primary.Ammo, false )
   self.Weapon:SetClip1( self.Weapon:Clip1() + 1 )

   wep:SendWeaponAnim(ACT_VM_RELOAD)

   self.reloadtimer = CurTime() + wep:SequenceDuration()
end

function SWEP:FinishReload()
   self.dt.reloading = false
   self.Weapon:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)

   self.reloadtimer = CurTime() + self.Weapon:SequenceDuration()
end

function SWEP:CanPrimaryAttack()
   if self.Weapon:Clip1() <= 0 then
      self:EmitSound( "Weapon_Shotgun.Empty" )
      self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
      return false
   end
   return true
end

function SWEP:Think()
   if self.dt.reloading and IsFirstTimePredicted() then
      if self.Owner:KeyDown(IN_ATTACK) then
         self:FinishReload()
         return
      end

      if self.reloadtimer <= CurTime() then

         if self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0 then
            self:FinishReload()
         elseif self.Weapon:Clip1() < self.Primary.ClipSize then
            self:PerformReload()
         else
            self:FinishReload()
         end
         return self.BaseClass.Think(self)
      end
   end
   return self.BaseClass.Think(self)
end

function SWEP:Deploy()
   self.dt.reloading = false
   self.reloadtimer = 0
   return self.BaseClass.Deploy(self)
end
