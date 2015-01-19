include("shared.lua")

local matBeam = Material("effects/spark")
function ENT:Draw()
	render.SetMaterial(matBeam)
	local pos = self:GetPos()
	local norm = self:GetVelocity():GetNormal()
	render.DrawBeam(pos + norm * 10, pos - norm * 54, 32, 1, 0, color_white)
end

function ENT:DrawOffScreen()
	local vOffset = self:GetPos()

	local emitter = self.Emitter
	emitter:SetPos(vOffset)
	for i=1, math.max(1, EFFECT_QUALITY * 1.5) do
		local particle
		if math.random(1, 2) == 1 then
			particle = emitter:Add("effects/muzzleflash2", vOffset + VectorRand():GetNormal() * math.Rand(4, 8))
		else
			particle = emitter:Add("sprites/glow04_noz", vOffset + VectorRand():GetNormal() * math.Rand(4, 8))
			particle:SetColor(255, 200, 0)
		end
		particle:SetDieTime(0.6)
		particle:SetStartAlpha(250)
		particle:SetEndAlpha(150)
		particle:SetStartSize(math.Rand(4.5, 9))
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-1, 1))
	end
end

function ENT:Initialize()
	self:DrawShadow(false)

	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 32)

	self:SetRenderBounds(Vector(-36, -36, -36), Vector(36, 36, 36))
end

function ENT:Think()
	self:DrawOffScreen()
	if not self.PlayedSound then
		self.PlayedSound = true
		self:EmitSound("nox/fireballwhoosh.ogg", 85, math.random(190, 230))
	end
end

function ENT:OnRemove()
	--self.Emitter:Finish()
end
