include("shared.lua")

util.PrecacheSound("weapons/physcannon/energy_sing_loop4.wav")
function ENT:Initialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(32, 48)

	self:DrawShadow(false)

	self.FireSound = CreateSound(self, "weapons/physcannon/energy_sing_loop4.wav")

	self.Col = team.GetColor(self:GetSkin()) or color_white
end

function ENT:Think()
	self.Emitter:SetPos(self:GetPos())
	self.FireSound:PlayEx(0.8, math.Clamp(self:GetVelocity():Length() * 0.2, 80, 255))
end

function ENT:OnRemove()
	self.FireSound:Stop()
	--self.Emitter:Finish()
	ExplosiveEffect(self:GetPos(), 170, 80, DMGTYPE_FIRE)
end

local matGlow = Material("sprites/light_glow02_add")
function ENT:Draw()
	local c = self.Col
	self:SetColor(Color(c.r, c.g, c.b, 255))
	self:DrawModel()

	local vOffset = self:GetPos()

	render.SetMaterial(matGlow)
	local size = 105 + math.sin(RealTime() * 40) * 38
	render.DrawSprite(vOffset, size, size, col)

	for i=0, EFFECT_QUALITY do
		local particle = self.Emitter:Add("effects/fire_cloud1", vOffset)
		particle:SetVelocity(VectorRand() * 16)
		particle:SetDieTime(1.5)
		particle:SetStartAlpha(220)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(24, 38))
		particle:SetEndSize(2)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-2, 2))
		--particle:SetColor(r,g,b)
	end
end
