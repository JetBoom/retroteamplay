AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.MoneyBonus = 30
ENT.OffenseBonus = 3
ENT.FragsBonus = 3
ENT.DestructionEffect = PROPGENERICDESTRUCTIONEFFECT2

function ENT:Initialize()
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then phys:EnableMotion(false) end
end

function ENT:Think()
	if self:AnchorEnabled() then
		for _, ent in pairs(ents.FindInSphere(self:GetPos(), self.Radius)) do
			if self:ShouldAnchor(ent) then
				ent:GiveStatus("anchor", 10).Hostile = true
			end
		end
	end

	self:NextThink(CurTime() + 0.2)
	return true
end

function ENT:AnchorEnabled()
	return not self.Destroyed
end

function ENT:ShouldAnchor(ent)
	return self:AnchorEnabled() and ent:IsPlayer() and not ent:IsAnchored() and ent:Alive() and ent:Team() ~= self:GetTeamID() and GAMEMODE:DrainPower(self, 10)
end
