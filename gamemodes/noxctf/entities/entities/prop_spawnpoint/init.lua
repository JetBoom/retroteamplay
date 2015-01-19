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

function ENT:Use(activator, caller)
	if self.Destroyed then return end
	if activator:IsPlayer() and activator:Team() == self:GetTeamID() then
		if activator.SpawnPoint == self then
			activator:PrintMessage(4, "You will no longer spawn here.")
			activator:SendLua([[surface.PlaySound("buttons/button19.wav")]])
			activator.SpawnPoint = nil
			return
		end
		activator.SpawnPoint = self
		activator:PrintMessage(4, "You will respawn here when you die.")
		activator:SendLua([[surface.PlaySound("buttons/button14.wav")]])
	end
end

function ENT:Info(pl)
	if pl:Team() == self:GetTeamID() then
		return self.PHealth..","..self.MaxPHealth..","..tostring(pl.SpawnPoint == self)
	end

	return "deny"
end

ENT.DestructionEffect = PROPGENERICDESTRUCTIONEFFECT
ENT.MoneyBonus = 20
ENT.OffenseBonus = 2
ENT.FragsBonus = 2
ENT.ProcessDamage = PROPGENERICPROCESSDAMAGE

function ENT:ProcessDamage(attacker, inflictor, dmginfo)
	dmginfo:SetDamage(dmginfo:GetDamage() * 4)
	PROPGENERICPROCESSDAMAGE(self, attacker, inflictor, dmginfo)
end
