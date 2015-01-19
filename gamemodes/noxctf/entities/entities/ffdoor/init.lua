AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_doors/door03_slotted_left.mdl")
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetTrigger(true)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then phys:EnableMotion(false) end
	self.Touching = 0
	self.TouchTable = {}

	--self:SetMaterial("models/props_combine/stasisshield_sheet")
	self:SetMaterial("models/debug/debugwhite")
end

function ENT:Think()
	local parent = self:GetParent()
	if self:GetCollisionGroup() == COLLISION_GROUP_NONE then
		--if not parent.Powered or parent.Destroyed then
		if parent.Destroyed then
			self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
			self:SetColor(Color(255, 255, 255, 0))
		end
	--elseif self.Touching < 1 and parent.Powered and not parent.Destroyed then
	elseif self.Touching < 1 and not parent.Destroyed then
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
		self:SetColor(Color(255, 255, 255, 255))
	end
end

function ENT:Touch(ent)
end

function ENT:StartTouch(ent)
	if ent:IsPlayer() and (self:GetParent():GetTeamID() == ent:Team() or ent:GetClassTable().Name == "Assassin") then
		self.TouchTable[ent] = true
		self.Touching = self.Touching + 1
		if 0 < self.Touching then
			self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
			self:SetColor(Color(255, 255, 255, 0))
		end
	end
end

function ENT:EndTouch(ent)
	if self.TouchTable[ent] then
		self.TouchTable[ent] = nil
		self.Touching = self.Touching - 1
		if self.Touching < 1 then
			self:SetCollisionGroup(COLLISION_GROUP_NONE)
			self:SetColor(Color(255, 255, 255, 255))
		end
	end
end

function ENT:ProcessDamage(attacker, inflictor, dmginfo)
	self:GetParent():TakeDamageInfo(dmginfo)
end
