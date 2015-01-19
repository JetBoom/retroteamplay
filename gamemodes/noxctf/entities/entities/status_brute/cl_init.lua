include("shared.lua")

ENT.Rotation = 0

function ENT:StatusInitialize()
	self:SetRenderBounds(Vector(-40, -40, -18), Vector(40, 40, 128))

	self.Emitter = ParticleEmitter(self:GetPos())
	self.AmbientSound = CreateSound(self, "player/heartbeat1.wav")
	self.Emitter:SetNearClip(34, 42)
end

function ENT:StatusThink(Owner)
	self.AmbientSound:PlayEx(0.85, 180)
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

function ENT:DrawTranslucent()
	local ent = self:GetOwner()
	if not ent:IsValid() then return end

	if ent:IsInvisible() then return end
	
	
	local pos
	if ent == MySelf and not ent:ShouldDrawLocalPlayer() then
		local aa, bb = ent:WorldSpaceAABB()
		pos = Vector(math.Rand(aa.x, bb.x), math.Rand(aa.y, bb.y), math.Rand(aa.z, bb.z))
	else
		pos = GetRandomBonePos(ent)
	end

	local emitter = self.Emitter
	for i = 1, 2 do
		local particle = emitter:Add("effects/splash1", pos + VectorRand():GetNormalized() * 2)
		particle:SetDieTime(math.Rand(0.2, 0.5))
		particle:SetStartSize(5)
		particle:SetEndSize(20)
		particle:SetColor(255,0,0)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetVelocity(ent:GetVelocity())
		particle:SetRoll(math.random(0, 360))
		particle = emitter:Add("sprites/glow04_noz", pos + VectorRand():GetNormalized() * 2)
		particle:SetDieTime(math.Rand(0.4, 0.5))
		particle:SetStartSize(20)
		particle:SetEndSize(40)
		particle:SetColor(255,0,0)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetVelocity(ent:GetVelocity())
		particle:SetRoll(math.random(0, 360))
		particle:SetRollDelta(math.random(5, -5))
	end

end

