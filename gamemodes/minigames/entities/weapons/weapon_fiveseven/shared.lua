AddCSLuaFile( "shared.lua" )

SWEP.PrintName			= "Five-Seven"
SWEP.Slot				= 1
SWEP.SlotPos			= 1

SWEP.ViewModelFOV		= 57
SWEP.ViewModelFlip		= false

SWEP.HoldType			= "pistol"
SWEP.Base				= "weapon_base_mg"
SWEP.Category			= "Secondary"

//Primary
SWEP.Primary.Automatic		= false
SWEP.Primary.Sound 			= Sound( "Weapon_FiveSeven.Single" )
SWEP.Primary.Recoil = 0.5
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0.01
SWEP.Primary.Damage = 24
SWEP.HeadshotMultiplier     = 2
SWEP.Primary.Delay = 0.200
SWEP.Primary.ClipSize = 20
SWEP.Primary.DefaultClip = 420
SWEP.Primary.Ammo           = "Pistol"


SWEP.Spawnable			= false
SWEP.AdminSpawnable		= true

SWEP.WorldModel = "models/weapons/w_pist_fiveseven.mdl"
SWEP.ViewModel	= "models/weapons/cstrike/c_pist_fiveseven.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.IronSightsPos = Vector(-5.961, -3.412, 3.039)
SWEP.IronSightsAng = Vector(-0.353, 0, 0)
SWEP.SightsPos = Vector(-5.961, -3.412, 3.039)
SWEP.SightsAng = Vector(-0.353, 0, 0)
SWEP.RunSightsPos = Vector(0, 0, 0)
SWEP.RunSightsAng = Vector(-9.469, -1.701, 0)
SWEP.Secondary.IronFOV			= 55
