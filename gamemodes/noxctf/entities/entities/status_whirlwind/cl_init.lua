include("shared.lua")

function ENT:StatusInitialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 32)
	
	self:EmitSound("ambient/wind/windgust.wav", 80, 120)
	
	self:SetRenderBounds(Vector(-256, -256, -256), Vector(256, 256, 256))
end

function ENT:StatusThink(owner)
	self.Emitter:SetPos(self:GetPos())
end

function ENT:Draw()
	local owner = self:GetOwner()
	if not owner:IsValid() then return end

	
	local pos = owner:GetPos() - Vector(0,0,4)

	local emitter = self.Emitter
	for i = 1, 10 do
		local displacementz = pos + Vector(0,0,8) * i
		local displacementxy = (i*6)/80 * 32 * VectorRand():GetNormal() * Vector(1,1,0)
		local particle = emitter:Add("particle/SmokeStack", displacementz + displacementxy)
		particle:SetStartSize(10)
		particle:SetEndSize(20)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetVelocity(500 * self:GetDir())
		particle:SetDieTime(math.Rand(0.1, .2))
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-3, 3))
		particle:SetColor(128, 128, 128)
		particle:SetCollide(true)
		particle:SetBounce(0.1)
	end
end