AddCSLuaFile( "shared.lua" )

SWEP.PrintName			= "Awp"
SWEP.Slot				= 0
SWEP.SlotPos			= 1

SWEP.ViewModelFOV		= 57
SWEP.ViewModelFlip		= false

SWEP.HoldType			= "ar2"
SWEP.Base				= "weapon_base_mg"
SWEP.Category			= "Primary"

//Primary
SWEP.Primary.Automatic		= true
SWEP.Primary.Sound 			= Sound( "Weapon_AWP.Single" )
SWEP.Secondary.Sound       = Sound("Default.Zoom")
SWEP.Primary.Recoil = 0.5
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 105
SWEP.HeadshotMultiplier = 3
SWEP.Primary.Delay = 1.4
SWEP.Primary.ClipSize = 10
SWEP.Primary.DefaultClip = 420
SWEP.Primary.Ammo           = "Pistol"

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= true

SWEP.WorldModel = "models/weapons/w_snip_awp.mdl"
SWEP.ViewModel	= "models/weapons/cstrike/c_snip_awp.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.IronSightsPos = Vector(-7.722, 0.827, 2.079)
SWEP.IronSightsAng = Vector(0.892, -0.81, -2.309)
SWEP.SightsPos = Vector( 5, -15, -2 )
SWEP.SightsAng = Vector( 2.6, 1.37, 3.5 )
SWEP.RunSightsPos = Vector(0, 0, 1.5)
SWEP.RunSightsAng = Vector(-7.739, 28.141, 0)
SWEP.Secondary.IronFOV = 0

function SWEP:SetZoom(state)
    if CLIENT then
       return
    elseif IsValid(self.Owner) and self.Owner:IsPlayer() then
       if state then
          self.Owner:SetFOV(20, 0.3)
       else
          self.Owner:SetFOV(0, 0.2)
       end
    end
end

-- Add some zoom to ironsights for this gun
function SWEP:SecondaryAttack()
    if not self.IronSightsPos then return end
   -- if self:GetNextSecondaryFire() > CurTime() then return end

	local bIronsights = self:GetIronsights()

    if SERVER then
        self:SetZoom(bIronsights)
     else
        self:EmitSound(self.Secondary.Sound)
    end

   -- self:SetNextSecondaryFire( CurTime() + 0.3)
end

function SWEP:PreDrop()
    self:SetZoom(false)
    self:SetIronsights(false)
    return self.BaseClass.PreDrop(self)
end

function SWEP:Reload()
	if ( self:Clip1() == self.Primary.ClipSize or self.Owner:GetAmmoCount( self.Primary.Ammo ) <= 0 ) then return end
    if self.isZoomingIronSight then return end
    self:DefaultReload( ACT_VM_RELOAD )
    self:SetIronsights( false )
    self:SetZoom( false )
end


function SWEP:Holster()
    self:SetIronsights(false)
    self:SetZoom(false)
    return true
end

if CLIENT then
    local scope = surface.GetTextureID("sprites/scope")
    function SWEP:DrawHUD()
        self.DrawCrosshair = false
        if self:GetIronsights() then
            surface.SetDrawColor( 0, 0, 0, 255 )

            local x = ScrW() / 2.0
            local y = ScrH() / 2.0
            local scope_size = ScrH()

            -- crosshair
            local gap = 80
            local length = scope_size
            surface.DrawLine( x - length, y, x - gap, y )
            surface.DrawLine( x + length, y, x + gap, y )
            surface.DrawLine( x, y - length, x, y - gap )
            surface.DrawLine( x, y + length, x, y + gap )

            gap = 0
            length = 50
            surface.DrawLine( x - length, y, x - gap, y )
            surface.DrawLine( x + length, y, x + gap, y )
            surface.DrawLine( x, y - length, x, y - gap )
            surface.DrawLine( x, y + length, x, y + gap )


            -- cover edges
            local sh = scope_size / 2
            local w = (x - sh) + 2
            surface.DrawRect(0, 0, w, scope_size)
            surface.DrawRect(x + sh - 2, 0, w, scope_size)

            surface.SetDrawColor(255, 0, 0, 255)
            surface.DrawLine(x, y, x + 1, y + 1)

            -- scope
            surface.SetTexture(scope)
            surface.SetDrawColor(255, 255, 255, 255)

            surface.DrawTexturedRectRotated(x, y, scope_size, scope_size, 0)

        else
            return self.BaseClass.DrawHUD(self)
        end
    end

   function SWEP:AdjustMouseSensitivity()
      return (self:GetIronsights() and 0.2) or nil
   end
end
