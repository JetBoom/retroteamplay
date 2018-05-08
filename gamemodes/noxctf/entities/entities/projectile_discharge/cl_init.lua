include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
end

local matBeam = Material("effects/spark")
function ENT:DrawTranslucent()
	local vOffset = self:GetPos()

	render.SetMaterial(matBeam)
	local norm = self:GetVelocity():GetNormal()
	render.DrawBeam(vOffset + norm * 10, vOffset - norm * 54, 32, 1, 0, color_white)

	local emitter = ParticleEmitter(vOffset)
	emitter:SetNearClip(24, 32)

	for i=1, 2 do
		local particle
		if math.random(1, 2) == 1 then
			particle = emitter:Add("effects/spark", vOffset + VectorRand():GetNormal() * math.Rand(4, 8))
		else
			particle = emitter:Add("sprites/glow04_noz", vOffset + VectorRand():GetNormal() * math.Rand(4, 8))
			particle:SetColor(0, 125, 255)
		end
		particle:SetDieTime(0.6)
		particle:SetStartAlpha(250)
		particle:SetEndAlpha(150)
		particle:SetStartSize(math.Rand(4.5, 9))
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-1, 1))
	end

	emitter:Finish()
end
