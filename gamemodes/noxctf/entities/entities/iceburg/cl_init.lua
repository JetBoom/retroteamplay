include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_wasteland/rockcliff01k.mdl")
	self:SetMaterial("models/shadertest/shader2")
	self.DeathTime = CurTime() + 10
	self.FadeTime = CurTime() + 9.5
	self.SpawnTime = CurTime() + 0.5
	self.Live = true
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then phys:EnableMotion(false) end
end

function ENT:Think()
	if self:GetmyHealth() <= 0 and self.Live then
		self.Live = false
		self.DeathTime = CurTime() + 0.5
		self.FadeTime = CurTime()
	end
end

function ENT:DrawTranslucent()
	if self.FadeTime > CurTime() then
		if CurTime() < self.SpawnTime then
			self:SetModelScale((1-(self.SpawnTime-CurTime())/0.5) * 1, 0)
		else
			self:SetModelScale(1, 0)
		end
	else
		self:SetModelScale(((self.DeathTime-CurTime())/(self.DeathTime-self.FadeTime)) * 1, 0)
	end
	render.SetBlend(0.5)
	self:DrawModel()
	render.SetBlend(1)
end