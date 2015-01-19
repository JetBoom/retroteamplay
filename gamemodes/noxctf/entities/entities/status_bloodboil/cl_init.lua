include("shared.lua")

function ENT:StatusInitialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(34, 42)
end

function ENT:StatusThink(owner)
	self.Emitter:SetPos(self:GetPos())
end

local function GetRandomBonePos(pl)
	if pl ~= MySelf or MySelf:ShouldDrawLocalPlayer() then
		local bone = pl:GetBoneMatrix(math.random(0, 25))
		if bone then
			return bone:GetTranslation()
		end
	end
	return pl:GetShootPos()
end
function ENT:DrawTranslucent()
	local owner = self:GetOwner()
	if not owner:IsValid() or not owner:IsVisibleTarget(MySelf) or owner == MySelf and not owner:ShouldDrawLocalPlayer() then return end
	
	local pos = GetRandomBonePos(owner)
	local emitter = self.Emitter
	for i=1, 2 do
		local particle = emitter:Add("sprites/glow04_noz", pos + VectorRand():GetNormalized() * 2)
		particle:SetColor(255, 0, 0, 255)
		particle:SetStartSize(16)
		particle:SetEndSize(0)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(127.5)
		particle:SetVelocity(Vector(0, 0, 128))
		particle:SetAirResistance(32)
		particle:SetDieTime(math.Rand(0.5, 0.9))
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-1.5, 1.5))
	end
end
