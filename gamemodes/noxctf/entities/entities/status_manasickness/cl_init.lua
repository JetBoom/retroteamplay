include("shared.lua")

function ENT:StatusInitialize()
	self:DrawShadow(false)
	self:SetRenderBounds(Vector(-40, -40, -18), Vector(40, 40, 48))

	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(28, 32)
end

function ENT:StatusThink()
	self.Emitter:SetPos(self:GetPos())
end

function ENT:Draw()
	local owner = self:GetOwner()
	if not owner:IsValid() or owner:IsInvisible() then return end

	local pos

	local attach = owner:GetAttachment(owner:LookupAttachment("mouth")) or owner:GetAttachment(owner:LookupAttachment("eyes"))
	if not attach then return end
	pos = attach.Pos + attach.Ang:Up() * -2
	
	local emitter = self.Emitter
	
	if not emitter then return end
	
	for i=1, 2 do
		particle = emitter:Add("sprites/light_glow02_add", pos + VectorRand())
		particle:SetVelocity(owner:GetVelocity() + Vector(0,0,40) + VectorRand() * 20)
		particle:SetDieTime(0.6)
		particle:SetStartAlpha(64)
		particle:SetEndAlpha(200)
		particle:SetStartSize(12)
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-10, 10))
		particle:SetColor(20, 120, 255)
		particle:SetGravity(Vector(0,0,-300))
		particle:SetCollide( true )
		particle:SetBounce( 0.2 )
	end
end
