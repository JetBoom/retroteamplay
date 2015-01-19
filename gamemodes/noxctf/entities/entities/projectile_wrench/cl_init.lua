include("shared.lua")

function ENT:Initialize()
	self:SetModelScale(1.3,0)
	self:DrawShadow(false)
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(28, 36)
	self.AmbientSound = CreateSound(self, "npc/combine_gunship/engine_rotor_loop1.wav")
	self.Col = self:GetOwner():GetPlayerColor() * 100
end

function ENT:Think()
	self:SetModelScale(1.3,0)
	self.AmbientSound:PlayEx(1,160)
	self.Emitter:SetPos(self:GetPos())
end

function ENT:OnRemove()
	--self.Emitter:Finish()
	self.AmbientSound:Stop()
end

function ENT:Draw()
	local owner = self:GetOwner()
	local pos, ang = self:GetPos(), self:GetAngles()
	
	self:DrawModel()
	
	local emitter = self.Emitter
	for i=1, 4 do
		local particle = emitter:Add("sprites/glow04_noz", pos + VectorRand():GetNormal() * 6 )
		particle:SetDieTime(math.Rand(0.5,1))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(3)
		particle:SetEndSize(0)
		particle:SetColor(self.Col.r,self.Col.g,self.Col.b)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-20, 20))
	end

end

