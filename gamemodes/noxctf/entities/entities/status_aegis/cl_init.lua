include("shared.lua")

ENT.NextEmit = 0

function ENT:StatusInitialize()
	self:SetModelScaleVector(Vector(0.15, 0.15, 0.1))

	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 32)
end

function ENT:StatusThink(owner)
	self.Emitter:SetPos(self:GetPos())
end

local col1 = Color(194, 178, 128)
local col2 = Color(240, 230, 140)
local matDust = Material("particle/smokestack")
function ENT:DrawTranslucent()
	local ent = self:GetOwner()
	if not ent:IsValid() or not ent:IsVisibleTarget(MySelf) then return end

	local oldpos = self:GetPos()

	local pos = ent:GetCenter()
	local ang = Angle(0, RealTime() * 270, 0)
	local count = 4
	local rotdelta = 360 / count

	self:SetRenderOrigin(ent:GetPos() + Vector(0, 0, ent:OBBMaxs().z + 16 + math.sin(RealTime() * 2) * 4))
	self:SetRenderAngles(ang)
	self:DrawModel()

	local emitting = self.NextEmit <= CurTime()
	if emitting then self.NextEmit = CurTime() + 0.075 end

	render.SetMaterial(matDust)
	for i=1, count do
		local endpos = pos + ang:Forward() * 48

		render.DrawSprite(endpos, 32, 32, col1)
		render.DrawSprite(endpos, 32, 32, col2)

		if emitting then
			for i=1, 2 do
				local particle = self.Emitter:Add("particle/smokestack", endpos + VectorRand():GetNormalized() * 6)
				particle:SetVelocity(ent:GetVelocity())
				particle:SetDieTime(math.Rand(0.3, 0.5))
				particle:SetStartAlpha(230)
				particle:SetEndAlpha(50)
				particle:SetStartSize(math.Rand(8, 10))
				particle:SetEndSize(0)
				particle:SetRoll(math.Rand(0, 360))
				particle:SetRollDelta(math.Rand(-0.8, 0.8))
				particle:SetColor(194, 178, 128)
				particle:SetAirResistance(50)
			end
		end

		if i < count then
			ang:RotateAroundAxis(ang:Up(), rotdelta)
		end
	end

	self:SetPos(oldpos)
end
