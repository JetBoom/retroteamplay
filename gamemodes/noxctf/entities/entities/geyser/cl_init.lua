include("shared.lua")

function ENT:Initialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 32)

	self:DrawShadow(false)

	self.AmbientSound = CreateSound(self, "ambient/water/water_flow_loop1.wav")
	self.AmbientSound:Play()
end

function ENT:OnRemove()
	self.AmbientSound:Stop()
	--self.Emitter:Finish()
end

function ENT:Think()
	local pos = self:GetPos()
	local emitter = self.Emitter
	
		
	if CurTime() <= self:GetEruptTime() then			
		for i = 1, (5 + math.ceil(self.Radius / 10)) do	
			local dir = VectorRand()
			dir.z = 0
			dir = dir:GetNormal()
			dir.z = math.Rand(0, .1)
		
			local particle = emitter:Add("effects/splash1", pos + math.random(0, self.Radius) * dir)
			particle:SetStartSize(5)
			particle:SetEndSize(20)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetDieTime(math.Rand(.8, 1.2))
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-1.5, 1.5))
			particle:SetColor(137, 207, 240)
			particle:SetCollide(true)
			particle:SetBounce(0.1)
		end
	else
		for i = 1, 5 do	
			local particle = emitter:Add("effects/splash2", pos + VectorRand():GetNormal() * 10 * Vector(1,1,0))
			particle:SetStartSize(5)
			particle:SetEndSize(20)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetVelocity(VectorRand():GetNormal() * 100 * Vector(1,1,0) + Vector(0, 0, 750))
			particle:SetGravity(Vector(0, 0, -750))
			particle:SetDieTime(math.Rand(1.4, 1.6)) 
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-1.5, 1.5))
			particle:SetColor(137, 207, 240)
			particle:SetCollide(true)
			particle:SetBounce(0.1)
		end
	end

	if not self.AmbientSound then
		self.AmbientSound = CreateSound(self, "ambient/water/water_flow_loop1.wav")
	end

	self.AmbientSound:PlayEx(0.8, 100 + math.sin(RealTime()))

	self:NextThink(CurTime())
	return true
end

function ENT:Draw()
end
