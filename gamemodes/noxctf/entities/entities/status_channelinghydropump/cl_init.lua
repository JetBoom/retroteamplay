include("shared.lua")

function ENT:StatusInitialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 32)

	self.AmbientSound = CreateSound(self, "vehicles/Airboat/pontoon_fast_water_loop1.wav")
	self.AmbientSound:Play()

	self:SetRenderBounds(Vector(-256, -256, -256), Vector(256, 256, 256))
end

function ENT:StatusThink(owner)
	self.Emitter:SetPos(self:GetPos())
	self.AmbientSound:PlayEx(0.8, 100 + math.sin(RealTime()))
end

function ENT:DrawTranslucent()
	local owner = self:GetOwner()
	if not owner:IsValid() then return end

	
	local pos = owner:GetShootPos()
	local ang = owner:EyeAngles()
	ang.pitch = math.Clamp(ang.pitch, -25, 25)
	local dir = ang:Forward()
	--[[local pos = owner:GetShootPos()
	local dir = owner:GetAimVector()
	dir.z = math.Clamp(dir.z, -0.2, 0.2)
	dir = dir:GetNormal()]]

	local emitter = self.Emitter
	for i = 1, 10 do
		local particle = emitter:Add("effects/splash2", pos)
		particle:SetStartSize(5)
		particle:SetEndSize(30)
		particle:SetStartAlpha((MySelf == owner and not owner:ShouldDrawLocalPlayer() and 5) or 255)
		particle:SetEndAlpha((MySelf == owner and not owner:ShouldDrawLocalPlayer() and 5) or 50)
		particle:SetVelocity(100 * (7.5 * dir + VectorRand():GetNormal() * math.Rand(0.8, 1.2)))
		particle:SetDieTime(math.Rand(0.8, 1.2))
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-3, 3))
		particle:SetColor(137, 207, 240)
		particle:SetCollide(true)
		particle:SetBounce(0.1)
	end
end
