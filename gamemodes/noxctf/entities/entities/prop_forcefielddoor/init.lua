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

	--self:Fire("evaluate", "", 0.1)

	local ent = ents.Create("ffdoor")
	if ent:IsValid() then
		ent:SetPos(self:GetPos() + self:GetRight() * 24 + self:GetUp() * -6)
		ent:SetAngles(self:GetAngles())
		ent:SetParent(self)
		ent:Spawn()
		if self.Destroyed then
			ent.Touching = ent.Touching + 1
			ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
			ent:SetColor(Color(255, 255, 255, 0))
		else
			ent:SetColor(Color(255, 255, 255, 255))
		end
		self.FF = ent
	end
end

function ENT:AcceptInput(name, activator, caller)
	if name == "created" then
		local ent = self.FF
		ent:SetCollisionGroup(COLLISION_GROUP_NONE)
		ent:SetColor(Color(255, 255, 255, 200))
		ent.Touching = math.max(0, ent.Touching - 1)

		return true
	--elseif name == "evaluate" then
	--	self:Fire("evaluate", "", 1)

	--	GAMEMODE:Evaluate(self)

	--	return true
	end
end

function ENT:Info(pl)
	if pl:Team() == self:GetTeamID() then
		--return self.PHealth..","..self.MaxPHealth..","..tostring(self.Powered)
		return self.PHealth..","..self.MaxPHealth
	end

	return "deny"
end

ENT.DestructionEffect = PROPGENERICDESTRUCTIONEFFECT
ENT.MoneyBonus = 30
ENT.OffenseBonus = 3
ENT.FragsBonus = 3
ENT.ProcessDamage = PROPGENERICPROCESSDAMAGE
