AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then phys:EnableMotion(false) end

	self.ManaStorage = 0
	self.MaxManaStorage = 100
end

function ENT:ManaReceived(from, amount)
	self:SetSkin(self.ManaStorage)
end

function ENT:Info(pl)
	if pl:Team() == self:GetTeamID() then
		return self.PHealth..","..self.MaxPHealth..","..self.MaxManaStorage
	end

	return "deny"
end

ENT.DestructionEffect = PROPGENERICDESTRUCTIONEFFECT
ENT.MoneyBonus = 20
ENT.OffenseBonus = 2
ENT.FragsBonus = 2
ENT.ProcessDamage = PROPGENERICPROCESSDAMAGE
