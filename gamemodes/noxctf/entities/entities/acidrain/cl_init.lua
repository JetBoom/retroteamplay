include("shared.lua")

ENT.NextEmit = 0

function ENT:OnRemove()
	if self.AmbientSound then self.AmbientSound:Stop() end
	--self.Emitter:Finish()
end

function ENT:Initialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 32)

	self:DrawShadow(false)

	if self:GetStartTime() == 0 then self:SetStartTime(CurTime() + 1) end

	self:EmitSound("ambient/atmosphere/thunder"..math.random(1, 4)..".wav", 90, 100)
	self:EmitSound("ambient/atmosphere/thunder"..math.random(1, 4)..".wav", 90, 90)

	self.AmbientSound = CreateSound(self, "ambient/water/water_flow_loop1.wav")
	self.AmbientSound:Play()
end

function ENT:Draw()
end

local function acidrainsplash(particle)
	particle:SetDieTime(0)

	--[[if math.random(1, 14) == 7 then
		local effectdata = EffectData()
			effectdata:SetOrigin(particle:GetPos())
			effectdata:SetNormal((VectorRand() + Vector(0, 0, 0.4)):GetNormal())
			effectdata:SetScale(150)
		util.Effect("acidraindrops", effectdata)
	end]]
end

function ENT:Think()
	if self.NextEmit <= CurTime() then
		self.NextEmit = CurTime() + (EFFECT_IQUALITY + 1) * 0.01

		local offset = VectorRand():GetNormal() * math.Rand(50, 350)
		offset.z = offset.z * 0.3

		local particle = self.Emitter:Add("particle/smokestack", self:GetPos() + offset)
		particle:SetDieTime(1.5)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(100)
		particle:SetEndSize(100)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-2.5, 2.5))
		if math.random(1,2) == 1 then
			particle:SetColor(42, 128, 0)
		else
			particle:SetColor(30, 77, 43)
		end
	end

	if CurTime() < self:GetStartTime() - .25 then return end

	if not self.AmbientSound then
		self.AmbientSound = CreateSound(self, "ambient/water/water_flow_loop1.wav")
	end

	self.AmbientSound:PlayEx(0.8, 100 + math.sin(RealTime())) -- Changing the pitch forces the sound to play if you leave and come back to the sound radius.

	for i=1, 2 * (EFFECT_QUALITY + 1) do
		local offset = VectorRand():GetNormal() * math.Rand(0, 250)
		offset.z = 0

		local particle = self.Emitter:Add("effects/spark", self:GetPos() + offset)
		particle:SetVelocity(Vector(0, 0, -1100))
		particle:SetColor(102, 255, 0)
		particle:SetDieTime(1.75)
		particle:SetStartAlpha(0)
		particle:SetEndAlpha(255)
		particle:SetStartSize(5)
		particle:SetEndSize(5)
		particle:SetCollide(true)
		particle:SetCollideCallback(acidrainsplash)
	end

	self:NextThink(CurTime())
	return true
end
