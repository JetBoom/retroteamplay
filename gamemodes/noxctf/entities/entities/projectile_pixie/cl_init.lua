include('shared.lua')

function ENT:Initialize()
	self:DrawShadow(false)

	--[[self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(28, 34)]]
end

function ENT:Think()
	--self.Emitter:SetPos(self:GetPos())
end

function ENT:OnRemove()
	----self.Emitter:Finish()
end

local matGlow = Material("sprites/light_glow02_add")
--local matBeam = Material("Effects/laser1.vmt")

function ENT:Draw()
	local vOffset = self:GetPos()

	render.SetMaterial(matGlow)
	render.DrawSprite(vOffset, math.Rand(24, 34), math.Rand(24, 34), color_white)
	render.DrawSprite(vOffset, 32, 36, COLOR_YELLOW)

	--[[render.SetMaterial(matBeam)
	local pos = self:GetPos()
	local norm = self:GetVelocity():GetNormal()
	local start = pos + norm * 8
	local endpos = pos - norm * 20
	render.DrawBeam(start, endpos, 10, 1, 0, COLOR_YELLOW)
	render.DrawBeam(start, endpos, 6, 1, 0, COLOR_YELLOW)]]

	--[[if EFFECT_QUALITY < 2 then return end

	local emitter = self.Emitter
	for i=1, EFFECT_QUALITY do
		local particle = emitter:Add("sprites/light_glow02_add", vOffset + VectorRand() * 4)
		particle:SetVelocity(VectorRand():GetNormal() * math.Rand(2, 8))
		particle:SetLifeTime(1)
		particle:SetDieTime(2)
		particle:SetStartAlpha(255)
		particle:SetStartSize(math.Rand(3.5, 5))
		particle:SetEndSize(0)
		particle:SetColor(255, 255, 70)
		particle:SetRoll(math.Rand(0, 359))
		particle:SetRollDelta(math.Rand(-2, 2))
		particle:SetAirResistance(30)
		particle:SetCollide(true)
		particle:SetBounce(0.5)
	end]]
end
