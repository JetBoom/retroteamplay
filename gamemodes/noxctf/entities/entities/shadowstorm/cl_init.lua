include("shared.lua")

function ENT:Initialize()
	self:SetRenderBounds(Vector(-300, -300, -300), Vector(300, 300, 300))
	self:DrawShadow(false)

	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 32)
	self.NextEmit = 0

	sound.Play("nox/toxiccloud.ogg", self:GetPos(), 80, math.Rand(65, 75))
end

function ENT:DrawTranslucent()
	local owner = self:GetOwner()
	local curtime = CurTime()
	if curtime < self.NextEmit then
		return true
	end

	if EFFECT_QUALITY == 0 then
		self.NextEmit = CurTime() + 0.25
	else
		self.NextEmit = CurTime() + 0.04 * math.max(1, EFFECT_IQUALITY)
	end

	local pos = self:GetPos()
	local emitter = self.Emitter

	local myteam = MySelf:GetTeamID()
	local ownerteam = owner:GetTeamID()
	for i=1, math.random(25, 30) do
		local particle = emitter:Add("particles/smokey", pos + Vector(math.Rand(-self.Radius, self.Radius), math.Rand(-self.Radius, self.Radius), 1):GetNormal() * math.Rand(self.Radius/8, self.Radius))
		particle:SetDieTime(0.9)
		particle:SetStartAlpha((myteam == ownerteam and 20) or 255)
		particle:SetEndAlpha((myteam == ownerteam and 20) or 255)
		particle:SetStartSize(30)
		particle:SetEndSize(30)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-3, 3))
		particle:SetCollide(true)
		particle:SetColor(51, 0, 99)
		particle:SetGravity(Vector(0, 0, math.Rand(150, 600)))
		particle:SetAirResistance(math.Rand(100, 140))
	end
end
