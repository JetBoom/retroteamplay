include("shared.lua")

function ENT:StatusInitialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(28, 32)
end

function ENT:StatusThink(owner)
	self.Emitter:SetPos(self:GetPos())
end

local function GetRandomBonePos(pl)
	if pl ~= MySelf or pl:ShouldDrawLocalPlayer() then
		local bone = pl:GetBoneMatrix(math.random(0,25))
		if bone then
			return bone:GetTranslation()
		end
	end

	return pl:GetShootPos()
end

function ENT:Draw()
	local ent = self:GetOwner()
	if not ent:IsValid() then return end
	
	if ent == MySelf and not ent:ShouldDrawLocalPlayer() then
		local pos = ent:GetPos()
		local emitter = self.Emitter
		for i = 1,5 do
			local particle = emitter:Add("sprites/flamelet"..math.random(1,4), pos + VectorRand():GetNormal() * 16 * Vector(1,1,0) + Vector(0,0,math.random(0,72)))
			particle:SetColor(255, 255, 255)
			particle:SetStartSize(5)
			particle:SetEndSize(10)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(127.5)
			particle:SetVelocity(ent:GetVelocity())
			particle:SetAirResistance(32)
			particle:SetDieTime(math.Rand(0.2, 0.5))
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-1.5, 1.5))
		end
	else
		local pos = GetRandomBonePos(ent)
		local emitter = self.Emitter
		for i = 1,2 do
			local particle = emitter:Add("sprites/flamelet"..math.random(1,4), pos + VectorRand():GetNormal() * 2)
			particle:SetColor(255, 255, 255)
			particle:SetStartSize(5)
			particle:SetEndSize(10)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(127.5)
			particle:SetVelocity(ent:GetVelocity())
			particle:SetAirResistance(32)
			particle:SetDieTime(math.Rand(0.2, 0.5))
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-1.5, 1.5))
		end
	end
end
