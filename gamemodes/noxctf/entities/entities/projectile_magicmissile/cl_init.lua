include("shared.lua")

local matFire = Material("sprites/glow04_noz")

function ENT:Draw()
	local pos = self:GetPos()

	render.SetMaterial(matFire)
	render.DrawSprite(pos, math.Rand(32, 48), math.Rand(32, 48), COLOR_YELLOW)

	local emitter = self.Emitter
	emitter:SetPos(pos)
	local particle = emitter:Add("effects/fire_embers"..math.random(1,3), pos)
	particle:SetDieTime(0.3)
	particle:SetStartAlpha(150)
	particle:SetEndAlpha(60)
	particle:SetStartSize(math.Rand(14, 20))
	particle:SetEndSize(2)
	particle:SetRoll(math.random(0, 360))
	for i=1, 4 do
		particle = emitter:Add("effects/fire_embers"..math.random(1,3), pos)
		particle:SetVelocity(self:GetVelocity() * -0.4 + VectorRand() * 50)
		particle:SetDieTime(0.3)
		particle:SetStartAlpha(150)
		particle:SetEndAlpha(60)
		particle:SetStartSize(math.Rand(10, 14))
		particle:SetEndSize(1)
		particle:SetRoll(math.random(0, 360))
	end
end

function ENT:Initialize()
	self:DrawShadow(false)

	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 32)
end

function ENT:Think()
	self.Emitter:SetPos(self:GetPos())
end

function ENT:OnRemove()
	--self.Emitter:Finish()
end
