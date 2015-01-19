include("shared.lua")

function ENT:Draw()
	local owner = self:GetOwner()
	if not owner:IsValid() then return end

	if owner:IsInvisible() then return end

	local pos
	if owner == MySelf and not owner:ShouldDrawLocalPlayer() then
		pos = MySelf:GetShootPos() + MySelf:GetAimVector() * 4 + MySelf:GetAimVector():Angle():Right() * 4
	else
		local attach = owner:GetAttachment(owner:LookupAttachment("anim_attachment_RH"))
		if attach then
			pos = attach.Pos
		end
	end

	if pos then
		local a = owner:GetVisibility()

		local emitter = self.Emitter
		for i=1, 2 do
			particle = emitter:Add("sprites/light_glow02_add", pos + VectorRand() * 2.5)
			particle:SetDieTime(0.6)
			particle:SetStartAlpha(a)
			particle:SetEndAlpha(a * 0.25)
			particle:SetStartSize(3)
			particle:SetEndSize(0)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-0.8, 0.8))
			particle:SetColor(30, 255, 30)
			particle:SetAirResistance(75)
			particle:SetGravity(Vector(0, 0, -200))
			particle:SetCollide(true)
		end
	end
end

function ENT:StatusInitialize()
	self.Emitter = ParticleEmitter(self:GetPos())

	if MySelf == self:GetOwner() then
		local c = MySelf:GetColor()
		MySelf:GetViewModel():SetColor(Color(30, 255, 30, c.a))
	end
end

function ENT:StatusThink(owner)
	self.Emitter:SetPos(self:GetPos())
end

function ENT:StatusOnRemove(owner)
	if MySelf == owner then
		MySelf:GetViewModel():SetColor(Color(255, 255, 255, 255))
	end
end
