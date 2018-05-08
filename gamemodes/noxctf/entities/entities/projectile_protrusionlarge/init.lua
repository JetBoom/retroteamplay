AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()

	self:SetModel("models/props_wasteland/rockcliff01c.mdl")

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

	util.ScreenShake(self:GetPos(), 10, 10, 1.25, 350)

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
		ent:TakeSpecialDamage(25, DMGTYPE_ICE, owner, self)
		if ent:IsPlayer() and ent:Team() ~= owner:GetTeamID() then
			ent:SetGroundEntity(NULL)
			ent:SetVelocity(Vector(0,0,420))
			ent:GiveStatus("knockdown",2)
		end
	end
end
