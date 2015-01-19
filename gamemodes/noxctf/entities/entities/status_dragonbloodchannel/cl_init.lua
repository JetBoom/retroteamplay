include("shared.lua")

function ENT:StatusInitialize()
	self:SetRenderBounds(Vector(-40, -40, -18), Vector(40, 40, 128))

	self.Emitter = ParticleEmitter(self:GetPos())
	self.AmbientSound = CreateSound(self, "ambient/creatures/leech_water_churn_loop2.wav")
	self.Emitter:SetNearClip(34, 42)
end

function ENT:StatusThink(Owner)
	self.AmbientSound:PlayEx(0.65, 50)
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

	if ent:IsInvisible() then return end
	
	
	local pos
	if ent == MySelf and not ent:ShouldDrawLocalPlayer() then
		local aa, bb = ent:WorldSpaceAABB()
		pos = Vector(math.Rand(aa.x, bb.x), math.Rand(aa.y, bb.y), math.Rand(aa.z, bb.z))
	else
		pos = GetRandomBonePos(ent)
	end

	local emitter = self.Emitter
	for i = 1, 3 do
		local particle = emitter:Add("effects/splash1", pos + VectorRand():GetNormalized() * 5)
		particle:SetDieTime(math.Rand(0.4, 0.8))
		particle:SetStartSize(30)
		particle:SetEndSize(1)
		particle:SetColor(95,0,0)
		particle:SetStartAlpha(75)
		particle:SetEndAlpha(0)
		particle:SetVelocity(ent:GetVelocity())
		particle:SetRoll(math.random(0, 360))
	end

end