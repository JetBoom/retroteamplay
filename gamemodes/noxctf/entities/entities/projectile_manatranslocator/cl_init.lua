include("shared.lua")

function ENT:Initialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(45, 50)

	self.AmbientSound = CreateSound(self, "ambient/atmosphere/city_beacon_loop1.wav")

	self.Col = self:GetColor()
	self.Seed = math.Rand(0, 10)
end

function ENT:Think()
	self.AmbientSound:PlayEx(0.75, 200)
	self.Emitter:SetPos(self:GetPos())
end

function ENT:OnRemove()
	--self.Emitter:Finish()
	self.AmbientSound:Stop()
end

local matGlow = Material("sprites/light_glow02_add")
function ENT:Draw()
	local vOffset = self:GetPos()

	local col = self.Col

	render.SetMaterial(matGlow)
	local rt = RealTime() + self.Seed
	local radius = math.cos(rt * 8) * 94 + 175
	local whiteradius = math.sin(rt * 8) * 24 + 48
	render.DrawSprite(vOffset, whiteradius, whiteradius, color_white)
	render.DrawSprite(vOffset, radius, radius, col)

	for i=1, 2 do
		local particle = self.Emitter:Add("sprites/light_glow02_add", vOffset + VectorRand():GetNormal() * math.Rand(2, 4))
		particle:SetVelocity(VectorRand():GetNormal() * math.Rand(8, 24))
		particle:SetDieTime(math.Rand(0.9, 1.25))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(255)
		particle:SetStartSize(math.Rand(5, 12))
		particle:SetEndSize(0)
		particle:SetColor(math.max(0, math.min(col.r + math.Rand(-30, 30), 255)), math.max(0, math.min(col.g + math.Rand(-30, 30), 255)), math.max(0, math.min(col.b + math.Rand(-30, 30), 255)))
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-3, 3))
	end
end
