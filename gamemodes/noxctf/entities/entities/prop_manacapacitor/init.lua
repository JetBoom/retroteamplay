AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

CAPACITORS = {}

function ENT:Initialize()
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then phys:EnableMotion(false) end

	self.ManaStorage = 0
	self.MaxManaStorage = 500

	table.insert(CAPACITORS, self)
end

function ENT:OnRemove()
	for i, cap in ipairs(CAPACITORS) do
		if cap == self then
			table.remove(CAPACITORS, i)
			break
		end
	end
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

ENT.DestructionEffect = PROPGENERICDESTRUCTIONEFFECT2
ENT.MoneyBonus = 30
ENT.OffenseBonus = 3
ENT.FragsBonus = 3
ENT.ProcessDamage = PROPGENERICPROCESSDAMAGE
