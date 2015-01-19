include("shared.lua")

util.PrecacheSound("physics/glass/glass_largesheet_break1.wav")
util.PrecacheSound("physics/glass/glass_largesheet_break2.wav")
util.PrecacheSound("physics/glass/glass_largesheet_break3.wav")

function ENT:Draw()
	local scale = math.max(0.05, self.DeathTime - CurTime())
	if scale >= 3.1 then
		local midscale = (3.4 - scale) * 2.5
		self:SetModelScale(midscale * (3.4 - scale) * 3.33, 0)
		self:SetColor(Color(0, 128, 128, math.min(255, scale * 500)))
	elseif scale < 3.1 and scale > .3 then
		self:SetModelScale(1, 0)
		self:SetColor(Color(0, 128, 128, math.min(255, 150)))
	elseif scale <= .3 then
		self:SetModelScale(scale * 2.5, 0)
		self:SetColor(Color(0, 128, 128, math.min(255, scale * 500)))
	end
	self:DrawModel()
end

function ENT:Initialize()
	self.DeathTime = CurTime() + 3.4
	self:SetMaterial("models/shadertest/shader2")
	ExplosiveEffect(self:GetPos(), 48, 30, DMGTYPE_ICE)
	
	local emitter = ParticleEmitter(self:GetPos())
	emitter:SetNearClip(24, 32)

	local ang = Angle(0,0,0)
	local up = Vector(0,0,1)
	local pos = self:GetPos()
	for i=1, 180 do
		ang:RotateAroundAxis(up, 2)
		local fwd = ang:Forward()
		local particle = emitter:Add("particle/snow", pos + fwd * 8)
		particle:SetVelocity(fwd * 32)
		particle:SetAirResistance(-32)
		particle:SetDieTime(2)
		particle:SetLifeTime(1)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(10)
		particle:SetEndSize(10)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-2, 2))

		local particle = emitter:Add("particle/snow", pos)
		particle:SetVelocity(fwd * 32 + Vector(0,0,16))
		particle:SetAirResistance(-64)
		particle:SetDieTime(2)
		particle:SetLifeTime(1)
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
		self:EmitSound("physics/glass/glass_largesheet_break"..math.random(1, 3)..".wav", 80, math.random(160, 180))
	end
	self.Played = true
end

function ENT:OnRemove()
end
