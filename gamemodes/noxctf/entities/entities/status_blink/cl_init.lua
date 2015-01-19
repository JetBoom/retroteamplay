include("shared.lua")

function ENT:StatusInitialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(28, 32)
end

function ENT:StatusOnRemove(owner)
	--self.Emitter:Finish()
end

function ENT:StatusThink(owner)
	self.Emitter:SetPos(self:GetPos())
end

local matGlow = Material("sprites/light_glow02_add")
function ENT:DrawTranslucent()
	local owner = self:GetOwner()
	if not owner:IsValid() or not owner:IsVisibleTarget(MySelf) then return end

	local delta = math.Clamp(self:GetDieTime() - CurTime(), 0, 2)
	local pos = owner:GetPos() + Vector(math.sin(RealTime() * 5) * delta * 48, math.cos(RealTime() * 5) * delta * 48, owner:OBBMaxs().z / 2)

	render.SetMaterial(matGlow)
	render.DrawSprite(pos, 64, 64, COLOR_CYAN)

	local emitter = self.Emitter
	for i=1, 2 do
		particle = emitter:Add("sprites/light_glow02_add", pos + delta * 4 * VectorRand():GetNormalized())
		particle:SetVelocity(delta * 8 * VectorRand():GetNormalized())
		particle:SetDieTime(0.5)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(255)
		particle:SetStartSize(math.max(1, delta * 11))
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(0, 360))
		particle:SetColor(math.Rand(0, 30), math.Rand(190, 230), math.Rand(230, 255))
		particle:SetGravity(Vector(0,0,-600))
		particle:SetBounce(0.8)
		particle:SetCollide(true)
	end
end
