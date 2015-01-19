AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/hunter/plates/plate8x8.mdl")

	self:PhysicsInit(SOLID_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then phys:EnableMotion(false) end
	self.Think = nil

	self.ManaStorage = 0
	self.MaxManaStorage = 2000
end

function ENT:Use(activator, caller)
	if self.Destroyed then return end
	if activator:IsPlayer() and activator:Team() == self:GetTeamID() then
		activator:SendLua("OpenVehicleMenu("..self:EntIndex()..")")
	end
end

function ENT:Info(pl)
	if pl:Team() == self:GetTeamID() then
		return self.PHealth..","..self.MaxPHealth..","..self.ManaStorage..","..self.MaxManaStorage
	end

	return "deny"
end

ENT.DestructionEffect = PROPGENERICDESTRUCTIONEFFECT2
ENT.MoneyBonus = 20
ENT.OffenseBonus = 3
ENT.FragsBonus = 3
ENT.ProcessDamage = PROPGENERICPROCESSDAMAGE
