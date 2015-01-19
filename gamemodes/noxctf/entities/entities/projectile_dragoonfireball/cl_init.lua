include('shared.lua')
util.PrecacheSound("ambient/explosions/exp4.wav")

local matFire = Material("sprites/light_glow02_add")

function ENT:Draw()
	render.SetMaterial(matFire)
	render.DrawSprite(self:GetPos(), math.random(16, 32), math.random(16, 32), color_white)
end

function ENT:DrawOffScreen()
	local vOffset = self:GetPos()

	local emitter = self.Emitter
	emitter:SetPos(vOffset)
		local particle = emitter:Add("effects/fire_embers"..math.random(1,3), vOffset)
		particle:SetDieTime(0.3)
		particle:SetStartAlpha(150)
		particle:SetEndAlpha(60)
		particle:SetStartSize(math.Rand(14, 20))
		particle:SetEndSize(2)
		particle:SetRoll(math.random(0, 360))
		for i=1, math.max(1, EFFECT_QUALITY * 4) do
			local offset = (self:GetVelocity():GetNormal()):Angle():Right() * math.sin(RealTime() * 12) * 100
			local voffset = Vector(0, 0, math.cos(RealTime()*12) * 100)
			particle = emitter:Add("effects/fire_embers"..math.random(1,3), vOffset)
			particle:SetVelocity(self:GetVelocity() * -0.75 + VectorRand() * 16 + offset + voffset)
			particle:SetDieTime(0.5)
			particle:SetStartAlpha(170)
			particle:SetEndAlpha(75)
			particle:SetStartSize(math.Rand(11, 18))
			particle:SetEndSize(2)
			particle:SetRoll(math.random(0, 360))

			particle = emitter:Add("effects/fire_embers"..math.random(1,3), vOffset)
			particle:SetVelocity(self:GetVelocity() * -0.75 + VectorRand() * 16 - offset - voffset)
			particle:SetDieTime(0.5)
			particle:SetStartAlpha(150)
			particle:SetEndAlpha(60)
			particle:SetStartSize(math.Rand(12, 16))
			particle:SetEndSize(1)
			particle:SetRoll(math.random(0, 360))

			particle = emitter:Add("sprites/light_glow02_add", vOffset)
			particle:SetVelocity(self:GetVelocity():Angle():Right() * math.random(-1, 1) * 128)
			particle:SetDieTime(1.25)
			particle:SetStartAlpha(200)
			particle:SetEndAlpha(20)
			particle:SetStartSize(math.random(12, 16))
			particle:SetEndSize(2)
			particle:SetColor(255, 200, 50)
			particle:SetRoll(math.random(0, 360))
			particle:SetBounce(0.5)
			particle:SetCollide(true)
		end
end

function ENT:Initialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(32, 48)

	self:DrawShadow(false)
end

function ENT:Think()
	if not self.PlayedSound then
		self.PlayedSound = true
		self:EmitSound("ambient/explosions/exp4.wav", 85, math.random(110, 125))
	end
	self:DrawOffScreen()
end

function ENT:OnRemove()
	--self.Emitter:Finish()
end
