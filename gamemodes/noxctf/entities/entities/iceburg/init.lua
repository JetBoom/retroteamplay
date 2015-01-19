AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")


function ENT:Initialize()
	self:SetModel("models/props_wasteland/rockcliff01k.mdl")
	self:SetMaterial("models/shadertest/shader2")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetAngles(Angle(180,math.random()*360,0))
	self.DeathTime = CurTime() + 10
	self.Live=true
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then phys:EnableMotion(false) end
	self:SetmyHealth(50)
end

function ENT:Think()
	if self.DeathTime <= CurTime() then
		self:Remove()
		return
	end
	if self:GetmyHealth() <= 0 and self.Live then
		self.Live = false
		self.DeathTime = CurTime() + 0.5
	end
end
