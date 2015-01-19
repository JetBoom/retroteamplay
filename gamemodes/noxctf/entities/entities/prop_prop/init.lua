AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.MoneyBonus = 10
ENT.OffenseBonus = 1
ENT.FragsBonus = 1
ENT.ProcessDamage = PROPGENERICPROCESSDAMAGE
ENT.DestructionEffect = PROPGENERICDESTRUCTIONEFFECT

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetRenderMode(RENDERMODE_TRANSALPHA)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then phys:EnableMotion(false) end
end

function ENT:Info(pl)
	if pl:Team() == self:GetTeamID() then
		return self.PHealth..","..self.MaxPHealth
	end

	return "deny"
end
