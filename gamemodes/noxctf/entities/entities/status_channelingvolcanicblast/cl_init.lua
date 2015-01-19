include("shared.lua")

ENT.RingSize = 200

function ENT:StatusInitialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 32)

	self:SetRenderBounds(Vector(-256, -256, -256), Vector(256, 256, 256))

	self:EmitSound("npc/strider/charging.wav", 78, 70)
end

function ENT:StatusThink(owner)
	self.Emitter:SetPos(self:GetPos())
end

local matRing = Material("effects/select_ring")
local colRing = Color(255, 120, 20, 255)
function ENT:DrawTranslucent()
	local ent = self:GetOwner()
	if not ent:IsValid() then return end

	if ent:IsInvisible() then return end

	local aim = ent:GetAimVector()
	local pos = ent:GetShootPos() + aim * 24
	pos.z = math.max(pos.z, 0.15)

	for i=1, 2 do
		local dir = VectorRand():GetNormal()
		particle = self.Emitter:Add("sprites/flamelet"..math.random(1, 4), pos + dir * 80)
		particle:SetVelocity(dir * -160)
		particle:SetDieTime(0.45)
		particle:SetStartAlpha(64)
		particle:SetEndAlpha(240)
		particle:SetStartSize(math.Rand(4, 6))
		particle:SetEndSize(math.Rand(8, 12))
		particle:SetRollDelta(math.Rand(-10, 10))
		particle:SetRoll(math.Rand(0, 360))
		particle:SetColor(255, math.Rand(180, 250), math.Rand(100, 200))
	end
	
	self.RingSize = self.RingSize - FrameTime() * 7 * self.RingSize
	if self.RingSize < 2 then self.RingSize = self.RingSize + 200 end

	local size = self.RingSize
	render.SetMaterial(matRing)
	render.DrawQuadEasy(pos, aim, size, size, colRing, size)
	render.DrawQuadEasy(pos, aim * -1, size, size, colRing, size)
end
