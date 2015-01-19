include("shared.lua")

function ENT:StatusInitialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 32)
	self.Col = self:GetOwner():GetPlayerColor() * 100
	self:DrawShadow(false)
	self:SetRenderBounds(Vector(-128, -128, -128), Vector(128, 128, 128))
	self:SetModel(self:GetOwner():GetModel()) 
end

function ENT:StatusThink(owner)
	self.Emitter:SetPos(self:GetPos() + self:GetUp() * 64)
end

function ENT:Draw()
	local owner = self:GetOwner()
	if not owner:IsValid() then return end

	local pos = owner:LocalToWorld(owner:OBBCenter()) + owner:GetForward() * 16
	local fwd = owner:GetForward()

	local c = self.Col
	local ct = CurTime()
	local vel = owner:GetVelocity() * -0.25 * fwd
	local fwdang = fwd:Angle()
	for i=1, 3 do
		local particle = self.Emitter:Add("effects/select_ring", pos)
		particle:SetVelocity(vel)
		particle:SetDieTime(0.4)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(2)
		particle:SetEndSize(72)
		particle:SetAngles(fwdang)
		particle:SetColor(c.r, c.g, c.b)
	end

	local ent = ClientsideModel(self:GetOwner():GetModel(), RENDERGROUP_TRANSLUCENT)
	ent:SetPos(owner:GetPos())
	ent:SetRenderMode( RENDERMODE_TRANSALPHA )
	ent:SetColor(Color(c.r,c.g,c.b,75))
	ent:SetAngles(self:GetOwner():GetAngles())
	ent:ResetSequence(owner:GetSequence())
	timer.Simple(0.6, function() ent:Remove() end)
end


