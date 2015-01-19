AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	if math.random(1, 2) == 1 then
		self:SetModel("models/props_wasteland/rockcliff01b.mdl")
	else
		self:SetModel("models/props_wasteland/rockcliff01c.mdl")
	end
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
	end

	self:SetTrigger(true)
	self:SetNotSolid(true)

	self.EndTime = CurTime() + 3
	self.Touched = {}
	self.DamageTimer = {}
	self.Think = nil

	self:Fire("kill", "", 3.4)

	self:SetMaterial("models/shadertest/shader2")

	for _, fire in pairs(ents.FindByClass("env_fire")) do
		if timer.Exists("burn"..fire:EntIndex()) and fire:GetPos():Distance(self:GetPos()) < 48 then
			fire:Remove()
		end
	end
end

function ENT:Touch(ent)
	if self.EndTime < CurTime() then return end

	local owner = self:GetOwner()
	if not owner:IsValid() then owner = self end
	
	if ent:IsValid() and ent:IsPlayer() and (ent:Team() ~= owner:Team() or ent == owner) then
		if not self.Touched[ent] then
			self.Touched[ent] = true
			ent:SoftFreeze(self.EndTime - CurTime())
		end
			
		if not self.DamageTimer[ent] or CurTime() >= self.DamageTimer[ent] then
			ent:TakeSpecialDamage(4, DMGTYPE_ICE, owner, self)
			self.DamageTimer[ent] = CurTime() + .33
		end
	end
end
