include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)

	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 48)

	self:SetColor(Color(0, 0, 0, 255))
	self:SetMaterial("models/debug/debugwhite")

	self:SetRenderBounds(Vector(-128, -128, -128), Vector(128, 128, 128))
	self.NextEmit = 0
	self.DeathTime = CurTime() + 4
	self:SetNWFloat("deathtime", CurTime() + 4)
	self.AmbientSound = CreateSound(self, "weapons/gauss/chargeloop.wav")
end

function ENT:Think()
	local lifepercent = (self.DeathTime - CurTime()) / 4
	
	self:SetModelScale(3.0 * lifepercent, 0)

	self.AmbientSound:PlayEx(1, math.max(80,(math.min(255,255 * (1-lifepercent)))))

	self.Emitter:SetPos(self:GetPos())

	if not self.PlayedSound then
		self.PlayedSound = true
		self:EmitSound("ambient/levels/citadel/portal_beam_shoot5.wav")
	end
end

function ENT:OnRemove()
	--self.Emitter:Finish()
	self.AmbientSound:Stop()
	self:EmitSound("weapons/physcannon/energy_sing_explosion2.wav")
end

local matHeatWave = Material("sprites/heatwave")
function ENT:Draw()
	self:DrawModel()

	local vPos = self:GetPos()
	local lifepercent = (self:GetNWFloat("deathtime",0) - CurTime()) / 4
	if lifepercent < 0 then return end

	render.SetMaterial(matHeatWave)
	render.DrawSprite(vPos, 240 * lifepercent, 240 * lifepercent, color_white)
	
	local emitter = self.Emitter
	emitter:SetPos(vPos)
	for i=1, 2 do
		local dir = VectorRand():GetNormal()
		local pos = vPos + 240 * lifepercent * dir
		local vel = lifepercent * -480 * dir
		local size = math.Rand(24, 32) * lifepercent

		local particle = emitter:Add("sprites/light_glow02_add", pos)
		particle:SetVelocity(vel)
		particle:SetDieTime(0.45)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(size * 0.5)
		particle:SetEndSize(0)
		particle:SetRollDelta(math.Rand(-10, 10))
		particle:SetRoll(math.Rand(0, 360))
		particle:SetColor(140, 140, 255)

		local particle = emitter:Add("particle/smokestack", pos)
		particle:SetVelocity(vel)
		particle:SetDieTime(0.45)
		particle:SetStartAlpha(200)
		particle:SetEndAlpha(0)
		particle:SetStartSize(size)
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-6, 6))
		particle:SetColor(0, 0, 0)
	end
end
