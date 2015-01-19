include("shared.lua")

function ENT:StatusInitialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 32)

	self:SetRenderBounds(Vector(-256, -256, -256), Vector(256, 256, 256))

	self:EmitSound("ambient/explosions/explode_6.wav", 78)
end

function ENT:StatusThink(owner)
	self.Emitter:SetPos(self:GetPos())
end

local matGlow = Material("sprites/light_glow02_add")
local colRing = Color(255, 120, 20, 255)
function ENT:DrawTranslucent()
	local ent = self:GetOwner()
	if not ent:IsValid() then return end

	if ent:IsInvisible() then return end

	local pos = ent:GetPos() + Vector(0,0,120)

	for i=1, 2 do
		local dir = VectorRand():GetNormal()
		particle = self.Emitter:Add("sprites/flamelet"..math.random(1, 4), pos)
		particle:SetVelocity(dir * math.random(100,400))
		particle:SetDieTime(0.45)
		particle:SetStartAlpha(64)
		particle:SetEndAlpha(240)
		particle:SetStartSize(math.Rand(4, 6))
		particle:SetEndSize(math.Rand(8, 12))
		particle:SetRollDelta(math.Rand(-10, 10))
		particle:SetRoll(math.Rand(0, 360))
		particle:SetColor(255, math.Rand(100, 150), math.Rand(80, 120))
	end
	
	if (self.EruptTime or 0) <= CurTime() then
		self.EruptTime = CurTime() + .75
		
		particle = self.Emitter:Add("sprites/light_glow02_add", pos)
		particle:SetDieTime(0.4)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(40)
		particle:SetStartSize(0)
		particle:SetEndSize(400)
		particle:SetRollDelta(math.Rand(-10, 10))
		particle:SetRoll(math.Rand(0, 360))
		particle:SetColor(self.TeamCol.r, self.TeamCol.g, self.TeamCol.b)
	end
end
