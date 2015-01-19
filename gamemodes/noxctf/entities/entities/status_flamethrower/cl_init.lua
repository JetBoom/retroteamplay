include("shared.lua")

function ENT:StatusInitialize()
	self:GetOwner():EmitSound("npc/ichthyosaur/attack_growl"..math.random(1,3)..".wav")

	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 32)

	self.AmbientSound = CreateSound(self, "ambient/fire/fire_med_loop1.wav")

	self:SetRenderBounds(Vector(-256, -256, -256), Vector(256, 256, 256))
end

function ENT:StatusThink(owner)
	self.Emitter:SetPos(self:GetPos())
	self.AmbientSound:PlayEx(1, 90 + math.sin(RealTime()))
end

function ENT:Draw()
	local owner = self:GetOwner()
	if not owner:IsValid() then return end

	
	local pos = owner:GetShootPos() + owner:GetAimVector() * 5
	local ang = owner:EyeAngles()
	local dir = ang:Forward()

	local emitter = self.Emitter
	for i = 1, 5 do
		local particle = emitter:Add("sprites/flamelet"..math.random(1,4), pos)
		particle:SetStartSize(5)
		particle:SetEndSize(20)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetVelocity(16 * (62 * dir + VectorRand():GetNormal() * math.Rand(0.9, 1.1)) + owner:GetVelocity())
		particle:SetGravity(Vector(0, 0, 1500))
		particle:SetDieTime(math.Rand(0.08, .12))
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-3, 3))
		particle:SetColor(255, math.Rand(180, 250), math.Rand(100, 200))
		particle:SetCollide(true)
		particle:SetBounce(0.1)
	end
end
