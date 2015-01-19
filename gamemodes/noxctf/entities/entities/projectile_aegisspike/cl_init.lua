include("shared.lua")

function ENT:Draw()
	self:DrawModel()
	if self.DeathTime - CurTime() >= .8 then
		self:SetModelScale(1.25 * (1 - (self.DeathTime - CurTime())) / .2, 0)
	elseif self.DeathTime - CurTime() < .8 and self.DeathTime - CurTime() > .2 then
		self:SetModelScale(1.25, 0)
	elseif self.DeathTime - CurTime() <= .2 then 
		self:SetModelScale(1.25 * (self.DeathTime - CurTime())/ .2, 0)
	end
end

function ENT:Initialize()
	self.DeathTime = CurTime() + 1
	
	local emitter = ParticleEmitter(self:GetPos())
	emitter:SetNearClip(24, 32)

	local ang = Angle(0, 0, 0)
	local up = Vector(0, 0, 1)
	local pos = self:GetPos()
	for i=1, 180 do
		ang:RotateAroundAxis(up, 2)
		local fwd = ang:Forward()
		local particle = emitter:Add("particle/smokestack", pos + fwd * 8)
		particle:SetVelocity(fwd * 128)
		particle:SetAirResistance(-32)
		particle:SetDieTime(2)
		particle:SetLifeTime(1)
		particle:SetColor(194, 178, 128)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(10)
		particle:SetEndSize(10)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-2, 2))

		local particle = emitter:Add("particle/smokestack", pos)
		particle:SetVelocity(fwd * 128 + Vector(0,0,16))
		particle:SetAirResistance(-64)
		particle:SetDieTime(2)
		particle:SetLifeTime(1)
		particle:SetColor(194, 178, 128)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(16)
		particle:SetEndSize(16)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-2, 2))
	end
end

function ENT:Think()
	if not self.Played then
		self:EmitSound("physics/concrete/concrete_break"..math.random(2, 3)..".wav")
		self.Played = true
	end
end
