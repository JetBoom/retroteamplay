include("shared.lua")

function ENT:StatusInitialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 32)

	self.NextQuakeEffect = CurTime() + self.QuakeInterval
end

function ENT:StatusThink(owner)
	self.Emitter:SetPos(self:GetPos())
end

function ENT:DrawTranslucent()
	local owner = self:GetOwner()
	if not owner:IsValid() then return end
	
	if self.NextQuakeEffect <= CurTime() then
		self.NextQuakeEffect = CurTime() + self.QuakeInterval
	
		local pos = owner:GetPos() + Vector(0, 0, 10)
		local emitter = self.Emitter
		local numparticles = 60
		local ang = owner:GetForward():Angle()

		for i=1, numparticles do
			local vel = ang:Forward()

			local particle = emitter:Add("particle/smokestack", pos + vel * 16)
			particle:SetStartSize(5)
			particle:SetEndSize(40)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetVelocity(vel * self.Radius + Vector(0, 0, 20))
			particle:SetDieTime(math.Rand(.9, 1.1))
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-1.5, 1.5))
			particle:SetColor(194, 178, 128)
			particle:SetCollide(true)
			particle:SetBounce(0.1)
			
			ang:RotateAroundAxis(ang:Up(), 360/numparticles)
		end
	end
end
