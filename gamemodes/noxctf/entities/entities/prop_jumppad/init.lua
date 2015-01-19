AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then phys:EnableMotion(false) end
	self.Think = nil
end

function ENT:StartTouch(ent)
	if not self:IsPlayerHolding() and not ent:IsPlayerHolding() then
		if ent:IsPlayer() then
			if (ent._nextjumppaduse or 0) <= CurTime() and ent:GetVelocity():Length() < 3000 then
				ent._nextjumppaduse = CurTime() + 1
				ent:SetGroundEntity(NULL)
				ent:SetVelocity(ent:GetVelocity() * 0.5 + self:GetUp() * 800)
				ent:Fire("ignorefalldamage", "4.2", 0)
				self:EmitSound("weapons/grenade_launcher1.wav", 80, 125)
			end
		elseif string.sub(ent:GetClass(), 1, 11) ~= "projectile_" then
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() and phys:IsMoveable() and phys:GetVelocity():Length() < 3000 then
				phys:SetVelocityInstantaneous(phys:GetVelocity() * 0.5 + self:GetUp() * 800)
				self:EmitSound("weapons/grenade_launcher1.wav", 80, 125)
			end
		end
	end
end

function ENT:Touch(ent)
end

function ENT:EndTouch(ent)
end

function ENT:Info(pl)
	if pl:Team() == self:GetTeamID() then
		return self.PHealth..","..self.MaxPHealth
	end

	return "deny"
end

ENT.DestructionEffect = PROPGENERICDESTRUCTIONEFFECT
ENT.MoneyBonus = 10
ENT.OffenseBonus = 1
ENT.FragsBonus = 1
ENT.ProcessDamage = PROPGENERICPROCESSDAMAGE
