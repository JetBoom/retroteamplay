util.PrecacheSound("npc/strider/charging.wav")

function EFFECT:Init(data)
	self.Ent = data:GetEntity()
	self.Aim = data:GetNormal()
	if self.Ent:IsValid() then
		self.Ent.ChargeFireBall = self
		self.DieTime = CurTime() + 1.25
		self.Ent:EmitSound("npc/strider/charging.wav", 85, math.random(100, 105))
	else
		self.DieTime = -1
	end
end

function EFFECT:Think()
	if self.Ent:IsValid() then
		self.Entity:SetPos(self.Ent:GetShootPos() + self.Ent:GetAimVector() * 16)
	end

	if self.DieTime <= CurTime() then
		if self.Ent:IsValid() then
			self.Ent.ChargeFireBall = nil
		end
		return false
	end

	return true
end

function EFFECT:Render()
	if not self.Ent:IsValid() then return end

	local timeleft = self.DieTime - CurTime()
	local aimvec = self.Aim
	local offset1 = (aimvec:Angle() + Angle(0,timeleft*3*20,0)):Forward() * 50
	local offset2 = (aimvec:Angle() + Angle(0,timeleft*3*-20,0)):Forward() * 50
	local pos = self.Ent:GetPos() + Vector(0,0,40)

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)
	for i=1, math.random(2, 4) do
		local particle = emitter:Add("effects/fire_cloud1", pos + offset1 + VectorRand() * 8)
		particle:SetVelocity(aimvec * 20 * (2 - timeleft))
		particle:SetDieTime(timeleft)
		particle:SetStartAlpha(math.Rand(220, 255))
		particle:SetEndAlpha(40)
		particle:SetStartSize(timeleft * 14 + math.Rand(1, 5))
		particle:SetEndSize(2)
		particle:SetRoll(math.random(0, 360))
		particle:SetRollDelta(0.25)

		particle = emitter:Add("effects/fire_cloud1", pos + offset2 + VectorRand() * 8)
		particle:SetVelocity(aimvec * 20 * (2 - timeleft))
		particle:SetDieTime(timeleft)
		particle:SetStartAlpha(math.Rand(220, 255))
		particle:SetEndAlpha(40)
		particle:SetStartSize(timeleft * 14 + math.Rand(1, 5))
		particle:SetEndSize(2)
		particle:SetRoll(math.random(0, 360))
		particle:SetRollDelta(0.25)
	end

	emitter:Finish()
end
