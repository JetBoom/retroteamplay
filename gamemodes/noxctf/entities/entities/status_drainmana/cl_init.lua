include("shared.lua")

ENT.NextEmit = 0
ENT.NextDrainSound = 0

function ENT:StatusInitialize()
	self:SetRenderBounds(Vector(1, 1, 1) * -self.MaxRange, Vector(1 ,1, 1) * self.MaxRange)

	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(16, 24)

	hook.Add("TranslateActivity", self, self.TranslateActivity)
end

function ENT:StatusThink(owner)
	self.Emitter:SetPos(self:GetPos())

	if CurTime() >= self.NextDrainSound then
		self.NextDrainSound = CurTime() + 0.45

		for i = 0, 3 do
			local target = self:GetTarget(i)
			if target:IsValid() then
				target:EmitSound("nox/manadraining.ogg", 80, math.Rand(95, 105))
			end
		end
	end
end

function ENT:DrawTranslucent()
	if CurTime() < self.NextEmit then return end
	self.NextEmit = CurTime() + 0.02

	local owner = self:GetOwner()
	if not owner:IsValid() then return end

	local emitter = self.Emitter
	local startpos = self:GetStartPos()
	for i = 0, 3 do
		local target = self:GetTarget()
		if target:IsValid() then
			local endpos = target:NearestPoint(startpos)
			for _ = 1, 4 do
				local particle = emitter:Add("sprites/glow04_noz", endpos + VectorRand():GetNormal() * math.Rand(4, 16))
				particle:SetVelocity(VectorRand():GetNormal() * math.Rand(4, 16) + (startpos - endpos))
				particle:SetDieTime(1.1)
				particle:SetStartAlpha(255)
				particle:SetEndAlpha(220)
				particle:SetStartSize(16)
				particle:SetEndSize(3)
				particle:SetRoll(math.Rand(0, 360))
				particle:SetRollDelta(math.Rand(-4, 4))
				particle:SetColor(60, 60, 255)
				particle:SetCollide(true)
				particle:SetBounce(0.75)
			end
		end
	end
end
