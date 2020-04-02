AddCSLuaFile( "shared.lua" )

SWEP.PrintName			= "M4A1"
SWEP.Slot				= 0
SWEP.SlotPos			= 1

SWEP.ViewModelFOV		= 57
SWEP.ViewModelFlip		= false

SWEP.HoldType			= "ar2"
SWEP.Base				= "weapon_base_mg"
SWEP.Category			= "Primary"

//Primary
SWEP.Primary.Automatic		= true
SWEP.Primary.Sound 			= Sound( "Weapon_M4A1.Single" )
SWEP.Secondary.IronFOV			= 55
SWEP.Primary.Recoil = 0.4
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0.01
SWEP.Primary.Damage = 23
SWEP.HeadshotMultiplier     = 3.5
SWEP.Primary.Delay = 0.13
SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 420
SWEP.Primary.Ammo           = "Pistol"


SWEP.Spawnable			= false
SWEP.AdminSpawnable		= true

SWEP.WorldModel = "models/weapons/w_rif_m4a1.mdl"
SWEP.ViewModel	= "models/weapons/cstrike/c_rif_m4a1.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.IronSightsPos = Vector(-7.875, -1.772, 0.159)
SWEP.IronSightsAng = Vector(3.144, -1.412, -3.07)
SWEP.SightsPos = Vector(-7.875, -1.772, 0.159)
SWEP.SightsAng = Vector(3.144, -1.412, -3.07)
SWEP.RunSightsPos = Vector(8.145, -8.968, -1.969)
SWEP.RunSightsAng = Vector(-1.667, 66.777, 0)
