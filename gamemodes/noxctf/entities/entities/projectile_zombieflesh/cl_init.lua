include("shared.lua")

local matPuke = Material("decals/Yblood1")
function ENT:Draw()
	render.SetMaterial(matPuke)
	local pos = self:GetPos()
	render.DrawSprite(pos, 32, 32, color_white)

	local emitter = ParticleEmitter(pos)
	emitter:SetPos(pos)
	emitter:SetNearClip(36, 44)

	local particle = emitter:Add("decals/Yblood"..math.random(1,6), pos + VectorRand():GetNormal() * math.Rand(1, 4))
	particle:SetVelocity(VectorRand():GetNormal() * math.Rand(1, 4))
	particle:SetDieTime(math.Rand(0.6, 0.9))
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(255)
	particle:SetStartSize(math.Rand(2, 5))
	particle:SetEndSize(0)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-1, 1))

	emitter:Finish()
end
