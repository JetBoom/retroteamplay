include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)

	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 32)

	self.Col = team.GetColor(self:GetSkin()) or color_white
	self:SetMaterial("models/props_wasteland/rockcliff04a")

	self.AmbientSound = CreateSound(self, "ambient/fire/fire_big_loop1.wav")
end

function ENT:Think()
	self.AmbientSound:Play()

	local vOffset = self:GetPos()

	local emitter = self.Emitter
	emitter:SetPos(vOffset)
	local particle = emitter:Add("effects/fire_embers"..math.random(1,3), vOffset)
	particle:SetDieTime(0.3)
	particle:SetStartAlpha(150)
	particle:SetEndAlpha(60)
	particle:SetStartSize(math.Rand(24, 32))
	particle:SetEndSize(0)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-1, 1))

	local col = self.Col
	local c = col.r * 0.5, col.g * 0.75, col.b * 0.75
	for i=1, math.max(1, EFFECT_QUALITY) do
		local particle = emitter:Add("effects/fire_embers"..math.random(1,3), vOffset)
		particle:SetVelocity(VectorRand():GetNormal() * math.Rand(4, 14))
		particle:SetDieTime(math.Rand(0.6, 1))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(20, 26))
		particle:SetEndSize(16)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-1, 1))

		local particle = emitter:Add("particles/smokey", vOffset + VectorRand():GetNormal() * 16)
		particle:SetVelocity(VectorRand():GetNormal() * math.Rand(12, 16))
		particle:SetDieTime(math.Rand(0.8, 1.2))
		particle:SetStartAlpha(100)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(12, 16))
		particle:SetEndSize(24)
		particle:SetColor(r, g, b)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-3, 3))
	end
end

function ENT:OnRemove()
	--self.Emitter:Finish()
	self.AmbientSound:Stop()
end

local matFire = Material("sprites/light_glow02_add")
function ENT:Draw()
	self:SetModelScale(0.75, 0)

	local c = self.Col
	self:SetColor(Color(c.r, c.g, c.b, 255))
	self:DrawModel()

	render.SetMaterial(matFire)
	render.DrawSprite(self:GetPos(), math.Rand(32, 48), math.Rand(32, 48), col)
end
