AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.MoneyBonus = 200
ENT.OffenseBonus = 5
ENT.FragsBonus = 5
ENT.ProcessDamage = PROPGENERICPROCESSDAMAGE
ENT.DestructionEffect = PROPGENERICDESTRUCTIONEFFECT2

function ENT:Initialize()
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then phys:EnableMotion(false) end

	self.ManaStorage = 0
	self.MaxManaStorage = 2500

	local ent = ents.Create("magusbubble")
	ent:SetPos(self:GetPos())
	ent:SetOwner(self)
	ent:Spawn()
	ent:SetParent(self)
end

function ENT:ManaReceived(from, amount)
	self:SetSkin(self.ManaStorage)
end

function ENT:Captured(oldteam, newteam)
	GAMEMODE:EvaluatePower()
end

function ENT:Info(pl)
	if pl:Team() == self:GetTeamID() then
		return self.PHealth..","..self.MaxPHealth..","..self.ManaStorage..","..self.MaxManaStorage
	end

	return "deny"
end

function ENT:AcceptInput(name, activator, caller, args)
	if name == "created" then
		GAMEMODE:EvaluatePower()
		return true
	end
end