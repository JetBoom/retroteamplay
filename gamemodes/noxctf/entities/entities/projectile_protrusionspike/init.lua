AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	if math.random(1, 2) == 1 then
		self:SetModel("models/props_wasteland/rockcliff01b.mdl")
	else
		self:SetModel("models/props_wasteland/rockcliff01c.mdl")
	end

	self:SetMaterial("models/shadertest/shader2")
	self:SetColor(Color(30, 150, 255, 255))
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
	end

	self:SetTrigger(true)
	self:SetNotSolid(true)

	self.EndTime = CurTime() + 0.6
	self.Touched = {}
	self.Think = nil

	self:Fire("kill", "", 1)

	for _, fire in pairs(ents.FindByClass("env_fire")) do
		if timer.Exists("burn"..fire:EntIndex()) and fire:GetPos():Distance(self:GetPos()) < 48 then
			fire:Remove()
		end
	end
end

function ENT:Touch(ent)
	if self.EndTime <= CurTime() then return end

	local owner = self:GetOwner()
	if not owner:IsValid() then owner = self end

	if ent ~= owner and ent:IsValid() and not self.Touched[ent] then
		self.Touched[ent] = true
		ent:TakeSpecialDamage(14, DMGTYPE_ICE, owner, self)
		if self:Freezes() then ent:SoftFreeze(self.EndTime - CurTime()) end
	end
end
