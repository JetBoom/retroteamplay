AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel(math.random(1, 2) == 1 and "models/props_wasteland/rockcliff01b.mdl" or "models/props_wasteland/rockcliff01c.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
	end

	self.EndTime = CurTime() + 1
	self.Think = nil
	self.Touched = {}

	self:Fire("kill", "", 1)
end

function ENT:Touch(ent)
	if self.EndTime <= CurTime() then return end
	
	local owner = self:GetOwner()
	if owner:IsValid() then
		if ent:IsValid() and ent.CounterSpell and not self.Touched[ent] then
			self.Touched[ent] = true
			CounterSpellEffect(owner, ent:GetPos(), 16)
		end
	end
end
