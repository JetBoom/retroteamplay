include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)

	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 32)

	self.AmbientSound = CreateSound(self, "ambient/atmosphere/noise2.wav")
end

function ENT:Think()
	self.AmbientSound:Play()

	local vOffset = self:GetPos()

	self.Emitter:SetPos(vOffset)

	if not self.PlayedSound then
		self.PlayedSound = true
		self:EmitSound("ambient/energy/weld1.wav", 180, math.Rand(95, 105))
	end
end

function ENT:OnRemove()
	self.AmbientSound:Stop()
	--self.Emitter:Finish()
end

local matGlow = Material("sprites/blueglow2")
local matRing = Material("effects/select_ring")
local matBeam = Material("Effects/laser1")
function ENT:DrawTranslucent()
	render.SetMaterial(matGlow)
	local pos = self:GetPos()
	render.DrawSprite(pos, math.Rand(32, 48), math.Rand(32, 48), color_white)
	render.SetMaterial(matRing)
	render.DrawSprite(pos, 32, 32, color_white)

	local emitter = self.Emitter
	emitter:SetPos(pos)
	for i=1, math.max(1, EFFECT_QUALITY * 0.6) do
		local heading = VectorRand():GetNormal()
		local particle = emitter:Add("effects/spark", pos + heading * 8)
		particle:SetVelocity(heading * 500)
		particle:SetDieTime(math.Rand(0.5, 0.85))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(255)
		particle:SetStartSize(math.Rand(4, 6))
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-25, 25))
		particle:SetAirResistance(80)
	end

	local heading = self:GetVelocity():GetNormal() * -1.3
	for i=1, math.max(5, EFFECT_QUALITY * 2.5) do
		local dir = (VectorRand() + heading):GetNormal()

		render.SetMaterial(matBeam)
		render.StartBeam(6)
		local bpos = pos + dir * 8
		for x=1, 6 do
			render.AddBeam(bpos, 64 - x * 5, x, Color(100, 200, 255, 255 - x * 25))
			dir:Rotate(Angle(math.Rand(-25, 25), math.Rand(-25, 25), 0))
			bpos = bpos + dir * 14
		end
		render.EndBeam()
	end
end
