AddCSLuaFile()
if SERVER then
    CreateConVar("quadgun_cubespeed", "80", FCVAR_ARCHIVE, "The speed of the cube")
    CreateConVar("quadgun_knockback_multiplier", "1", FCVAR_ARCHIVE, "Knockback multiplier")
    CreateConVar("quadgun_remove_time", "10", FCVAR_ARCHIVE, "Time (in seconds) before the entity remove itself. Should not be 0")
end

SWEP.Base = "weapon_base_master"
SWEP.PrintName = "Quad Gun"
SWEP.Author = "Cryx & Ipro"
SWEP.Purpose = "The Quad Gun came back! I love shooting cubes!"
SWEP.Instructions = "The only attack is for shooting cubes, be careful to not kill yourself!"
SWEP.Category = "Other"
SWEP.Contact = "Steam"

SWEP.Slot = 4
SWEP.SlotPos = 1

SWEP.Spawnable = true
SWEP.ViewModel = Model( "models/weapons/c_pistol.mdl" )
SWEP.WorldModel = Model( "models/weapons/w_pistol.mdl" )
SWEP.ViewModelFOV = 54
SWEP.UseHands = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.ViewModelFlip = false

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

SWEP.DrawAmmo = false
SWEP.AdminOnly = false

local shootSound = Sound("bigLaser.wav")
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

	surface.SetDrawColor(XHairRed:GetInt(), XHairGreen:GetInt(), XHairBlue:GetInt(), 150)
	surface.DrawRect(x - (thick/2), y - (size + gap/2), thick, size )
	surface.DrawRect(x - (thick/2), y + (gap/2), thick, size )
	surface.DrawRect(x + (gap/2), y - (thick/2), size, thick )
	surface.DrawRect(x - (size + gap/2), y - (thick/2), size, thick )
	if dotsize then
		surface.DrawRect(x - (dotsize/2), y - (dotsize/2), dotsize, dotsize)
	end
end


function SWEP:Initialize()
end

function SWEP:PrimaryAttack()
    if SERVER then
        local speedEnt = GetConVarNumber("quadgun_cubespeed")
        local quadgun_knockback_multiplier = GetConVarNumber("quadgun_knockback_multiplier")
        local forwardLook = self.Owner:EyeAngles():Forward()

        local cube = ents.Create("ent_quad_cube")
        if IsValid(cube) then

            cube:SetPos( self.Owner:GetShootPos() + forwardLook * 32 )
		    cube:SetAngles( self.Owner:EyeAngles() )
            cube:Spawn()
            cube:Activate()
            cube:SetOwner( self.Owner )
            cube:GetPhysicsObject():SetVelocity( self.Owner:GetForward() * speedEnt)

            self.Owner:SetVelocity(-forwardLook * 320 * quadgun_knockback_multiplier)
        end
    end

    self:SetNextPrimaryFire( CurTime() + 2 )
    self:EmitSound(shootSound)
    self:ShootEffects(self)
end

function SWEP:DrawHUD()
    local wep = LocalPlayer():GetActiveWeapon()
    if XHairEnabled:GetInt() == 1 and IsValid(wep) and !wep.NoCross then
       DrawCrosshair( ScrW()/2 + 1, ScrH()/2 + 2)
    end
end

function SWEP:SecondaryAttack()
end
