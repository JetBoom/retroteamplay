include("shared.lua")

function ENT:Initialize()
	self:SetRenderBounds(Vector(-300, -300, -300), Vector(300, 300, 300))
	self:DrawShadow(false)

	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 32)
	self.NextEmit = 0

	sound.Play("nox/toxiccloud.ogg", self:GetPos(), 80, math.Rand(95, 105))
end

function ENT:DrawTranslucent()
	local curtime = CurTime()
	if curtime < self.NextEmit then
		return true
	end

	if EFFECT_QUALITY == 0 then
		self.NextEmit = CurTime() + 0.25
	else
		self.NextEmit = CurTime() + 0.04 * math.max(1, EFFECT_IQUALITY)
	end

	local pos = self:GetPos()
	local emitter = self.Emitter

	if EFFECT_QUALITY < 2 then
		if self:GetSkin() == 1 then
			local particle = emitter:Add("effects/fire_cloud"..math.random(1,2), pos + VectorRand():GetNormal() * math.Rand(16, 32))
			particle:SetDieTime(0.75)
			particle:SetStartAlpha(255)
			particle:SetStartSize(math.Rand(140, 170))
			particle:SetEndSize(0)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-3, 3))
			particle:SetCollide(true)
			particle:SetAirResistance(math.Rand(100, 140))
		else
			local particle = emitter:Add("particles/smokey", pos)
			particle:SetDieTime(0.75)
			particle:SetStartAlpha(220)
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.Rand(128, 150))
			particle:SetEndSize(40)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-4, 4))
			particle:SetCollide(true)
			particle:SetColor(10, 255, 10)
			particle:SetGravity(Vector(0, 0, math.Rand(150, 600)))
			particle:SetAirResistance(math.Rand(100, 140))
		end
	else
		if self:GetSkin() == 1 then
			for i=1, math.random(2, 5) do
				local particle = emitter:Add("effects/fire_cloud"..math.random(1,2), pos + Vector(math.Rand(-128, 128), math.Rand(-128, 128), 1):GetNormal() * math.Rand(16, 90))
				particle:SetDieTime(0.9)
				particle:SetStartAlpha(255)
				particle:SetStartSize(math.Rand(24, 32))
				particle:SetEndSize(0)
				particle:SetRoll(math.Rand(0, 360))
				particle:SetRollDelta(math.Rand(-3, 3))
				particle:SetCollide(true)
				particle:SetGravity(Vector(0, 0, math.Rand(150, 600)))
				particle:SetAirResistance(math.Rand(100, 140))
			end
		else
			for i=1, math.random(2, 5) do
				local particle = emitter:Add("particles/smokey", pos + Vector(math.Rand(-128, 128), math.Rand(-128, 128), 1):GetNormal() * math.Rand(16, 90))
				particle:SetDieTime(0.9)
				particle:SetStartAlpha(220)
				particle:SetEndAlpha(0)
				particle:SetStartSize(math.Rand(16, 24))
				particle:SetEndSize(15)
				particle:SetRoll(math.Rand(0, 360))
				particle:SetRollDelta(math.Rand(-3, 3))
				particle:SetCollide(true)
				particle:SetColor(10, 255, 10)
				particle:SetGravity(Vector(0, 0, math.Rand(150, 600)))
				particle:SetAirResistance(math.Rand(100, 140))
			end
		end
	end
end
