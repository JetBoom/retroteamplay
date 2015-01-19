include("shared.lua")

function ENT:StatusInitialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(32, 40)

	self.DieTime = CurTime() + self.LifeTime

	self.Headings = {}

	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 32)

	for i=1, math.random(6, 8) do
		table.insert(self.Headings, VectorRand():GetNormal())
	end
end

local matGlow = Material("sprites/glow04_noz")
local colStart = Color(10, 255, 255, 255)
local colEnd = Color(10, 255, 10, 255)
local colGlow = Color(255, 255, 255, 255)
function ENT:Draw()
	local ent = self:GetOwner()
	if ent and ent:IsValid() and CurTime() < self.DieTime then
		local delta = (self.DieTime - CurTime()) / self.LifeTime
		local size = (1 - delta) * 32

		local rate = delta * 255
		colGlow.r = math.Approach(colEnd.r, colStart.r, rate)
		colGlow.g = math.Approach(colEnd.g, colStart.g, rate)
		colGlow.b = math.Approach(colEnd.b, colStart.b, rate)

		local pos = ent:LocalToWorld(ent:OBBCenter())

		local distance = math.min(1, delta * 2) * 64

		render.SetMaterial(matGlow)
		for _, heading in pairs(self.Headings) do
			local spritepos = pos + heading * distance

			render.DrawSprite(spritepos, size, size, colGlow)

			if math.random(0, 1) == 1 then
				local particle = self.Emitter:Add("sprites/glow04_noz", spritepos)
				particle:SetDieTime(0.5, 0.75)
				particle:SetStartSize(size * 0.5)
				particle:SetEndSize(0)
				particle:SetStartAlpha(255)
				particle:SetEndAlpha(0)
				particle:SetRoll(math.Rand(0, 360))
				particle:SetRollDelta(math.Rand(-10, 10))
				particle:SetColor(colGlow.r, colGlow.g, colGlow.b)
			end
		end
	end
end
