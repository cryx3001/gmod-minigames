AddCSLuaFile()
if SERVER then
    CreateConVar("quadgun_damage", "100", FCVAR_ARCHIVE, "Damage value")
end

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName= "QuadCube"
ENT.Author= "Cryx"
ENT.Contact= "Via steam"
ENT.Purpose= "DON'T TOUCH IT PLEASE"
ENT.Instructions= "BE CAREFUL"

ENT.Spawnable = false
ENT.AdminSpawnable = false


local damageCube = GetConVarNumber("quadgun_damage")

local dmginfo = DamageInfo()
dmginfo:SetDamage(500)
dmginfo:SetDamageType(DMG_DISSOLVE)

function ENT:Initialize()
    self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
    self:SetMaterial("models/shiny")
	self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )
    self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)

    if SERVER then
        self:PhysicsInit( SOLID_VPHYSICS )
        local entityToPhysObj = self:GetPhysicsObject()
        entityToPhysObj:EnableGravity(false)
        entityToPhysObj:EnableDrag(false)

        local quadgun_removeTime = GetConVarNumber("quadgun_remove_time")

    end

    timer.Create("colorrainbow", 0.06, 0, function()
        if IsValid(self) then
            local col = HSVToColor( CurTime() % 6 * 60, 1, 1 )
            self:SetColor(Color( col.r, col.g, col.b, 1 ))
        end
    end)
end

if SERVER then
    function ENT:Think()
        for k, v in pairs(ents.FindInSphere(self:GetPos(),5)) do
            if(v:IsPlayer() and v:Alive()) or v:IsNPC() and v:IsValid() then
                if IsValid(self.Owner) then
                    dmginfo:SetAttacker(self.Owner)
                    dmginfo:SetDamage(500)
                else
                    dmginfo:SetAttacker(self)
                    dmginfo:SetDamage(500)
                end
                v:TakeDamageInfo(dmginfo)
            end
        end
    end
end
