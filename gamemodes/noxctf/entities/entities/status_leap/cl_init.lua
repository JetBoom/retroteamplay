include("shared.lua")

function ENT:StatusInitialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 32)

	local owner = self:GetOwner()
	if owner:IsValid() then
		local pos = owner:GetPos() + Vector(0, 0, 10)
		local emitter = self.Emitter
		local numparticles = 60
		local ang = owner:GetForward():Angle()

		for i=1, numparticles do
			local vel = ang:Forward()

			local particle = emitter:Add("particle/smokestack", pos + vel)
			particle:SetStartSize(5)
			particle:SetEndSize(40)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetVelocity(vel * 250 + Vector(0, 0, 20))
			particle:SetDieTime(math.Rand(.4, .6))
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-1.5, 1.5))
			particle:SetColor(194, 178, 128)
			particle:SetCollide(true)
			particle:SetBounce(0.1)
			
			ang:RotateAroundAxis(ang:Up(), 360/numparticles)
		end
	end

	hook.Add("GetFallDamage", self, self.GetFallDamage)
end

function ENT:DrawTranslucent()
	local owner = self:GetOwner()
	if not owner:IsValid() then return end
	local vOffset = owner:GetCenter()
	local dir = VectorRand():GetNormal()
	local vel = VectorRand():GetNormal()
	local delta = math.abs(owner:GetVelocity().z/self.JumpVelocity)

	local emitter = self.Emitter
	local particle = emitter:Add("effects/yellowflare", vOffset)
	particle:SetDieTime(0.1)
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(100)
	particle:SetStartSize(10)
	particle:SetEndSize(math.max(10, 160 * delta))
	particle:SetRoll(math.Rand(0, 360))
	particle:SetGravity(Vector(0, 0, 10))

	local particle = emitter:Add("effects/yellowflare", vOffset)
	particle:SetDieTime(0.25)
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(100)
	particle:SetStartSize(10)
	particle:SetEndSize(math.max(160 * delta))
	particle:SetRoll(math.Rand(0, 360))
	particle:SetGravity(Vector(0, 0, 10))

	local particle = emitter:Add("effects/yellowflare", vOffset)
	particle:SetDieTime(0.2)
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(0)
	particle:SetStartSize(20)
	particle:SetEndSize(math.max(20, 240 * delta))
	particle:SetRoll(math.Rand(0, 360))
	particle:SetGravity(Vector(0, 0, 10))
	particle:SetColor(255, 30, 0)
end

function ENT:StatusOnRemove(owner)
	local owner = self:GetOwner()
	if owner:IsValid() then
		
		local vOffset = self:GetEffectPos()
		local delta = self:GetDelta()
		local rad = math.Clamp(self.DamageRadius * delta, 0, self.DamageRadius * 2)

		local emitter = self.Emitter
		for i = 1, 75 do
			local dir = Vector(math.random(-1, 1), math.random(-1, 1), math.random(.3, 1))
			dir:Normalize()

			local particle = emitter:Add("effects/yellowflare", vOffset)
			particle:SetDieTime(.25)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(100)
			particle:SetStartSize(10)
			particle:SetEndSize(math.max(10, 80 * delta))
			particle:SetRoll(math.Rand(0, 360))
			particle:SetVelocity(dir * rad * 4)

			local particle = emitter:Add("effects/yellowflare", vOffset)
			particle:SetDieTime(0.25)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(100)
			particle:SetStartSize(10)
			particle:SetEndSize(math.max(10, 80 * delta))
			particle:SetRoll(math.Rand(0, 360))
			particle:SetVelocity(dir * rad * 4)

			local particle = emitter:Add("effects/yellowflare", vOffset)
			particle:SetDieTime(0.25)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(20)
			particle:SetEndSize(math.max(20, 120 * delta))
			particle:SetRoll(math.Rand(0, 360))
			particle:SetColor(255, 30, 0)
			particle:SetVelocity(dir * rad * 4)
		end
	end
end