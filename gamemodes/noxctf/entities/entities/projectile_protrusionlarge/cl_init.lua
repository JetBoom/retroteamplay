include("shared.lua")

util.PrecacheSound("physics/glass/glass_largesheet_break1.wav")
util.PrecacheSound("physics/glass/glass_largesheet_break2.wav")
util.PrecacheSound("physics/glass/glass_largesheet_break3.wav")

function ENT:DrawTranslucent()
	local scale = math.max(0.05, self.DeathTime - CurTime())
	local icea
	if scale > 0.75 then
		local midscale = (1 - scale) * 2.3
		self:SetModelScale(midscale * (1 - scale) * 2, 0)
		icea = 1 - scale
	else
		self:SetModelScale(scale * 2.3, 0)
		icea = scale
	end
	render.SetBlend(icea)
	self:DrawModel()
	render.SetBlend(1)
end

function ENT:Initialize()
	self:SetRenderBounds( Vector( -64, -64, -64), Vector( 64, 64, 64))
	self.DeathTime = CurTime() + 1
	self:SetColor(Color(30, 150, 255, 255))
	self:SetMaterial("models/shadertest/shader2")
	ExplosiveEffect(self:GetPos(), 48, 100, DMGTYPE_ICE)

	self:EmitSound("physics/glass/glass_largesheet_break"..math.random(1, 3)..".wav", 75, math.random(160, 180))
	self:EmitSound("physics/glass/glass_largesheet_break"..math.random(1, 3)..".wav", 75, math.random(160, 180))
	self:EmitSound("physics/glass/glass_largesheet_break"..math.random(1, 3)..".wav", 75, math.random(160, 180))

	local emitter = ParticleEmitter(self:GetPos())
	emitter:SetNearClip(40, 48)

	local ang = Angle(0,0,0)
	local up = Vector(0,0,1)
	local pos = self:GetPos()
	for i=1, 40 do
		ang:RotateAroundAxis(up, 9)
		local fwd = ang:Forward()
		local particle = emitter:Add("particle/snow", pos + fwd * 8)
		particle:SetVelocity(fwd * 64)
		particle:SetAirResistance(-64)
		particle:SetDieTime(2)
		particle:SetLifeTime(1)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(10)
		particle:SetEndSize(10)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-2, 2))

		local particle = emitter:Add("particle/snow", pos)
		particle:SetVelocity(fwd * 64 + Vector(0,0,32))
		particle:SetAirResistance(-128)
		particle:SetDieTime(2)
		particle:SetLifeTime(1)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(16)
		particle:SetEndSize(16)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-2, 2))
	end

	emitter:Finish()
end

function ENT:Think()
	self:SetAngles(Angle(0, RealTime() * 50, 0))
end

function ENT:OnRemove()
end
