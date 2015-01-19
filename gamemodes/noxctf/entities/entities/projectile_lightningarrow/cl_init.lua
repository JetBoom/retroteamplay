include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
	self.TrailPositions = {}
	self.TrailPositions2 = {}
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(30, 40)
end

function ENT:Think()
	if 0 < self:GetVelocity():Length() then
		table.insert(self.TrailPositions, 1, self:GetPos())
		table.insert(self.TrailPositions, 1, self:GetPos() + VectorRand())
		if self.TrailPositions[16] then
			table.remove(self.TrailPositions, 16)
			table.remove(self.TrailPositions2, 16)
		end
		self:SetRenderBoundsWS(self.TrailPositions[#self.TrailPositions], self:GetPos() + self:GetForward() * 8, Vector(32, 32, 32))
	elseif self.TrailPositions[1] then
		table.remove(self.TrailPositions, #self.TrailPositions)
		table.remove(self.TrailPositions2, #self.TrailPositions2)
	end

	local ft = FrameTime()
	for i, pos in ipairs(self.TrailPositions2) do
		self.TrailPositions2[i] = pos + ft * 1500 * VectorRand():GetNormal()
	end
end

function ENT:OnRemove()
	--self.Emitter:Finish()
end

local matTrail = Material("Effects/laser1")
function ENT:DrawTranslucent()
	self:SetMaterial("models/shiny")
	self:DrawModel()

	local numtrails = #self.TrailPositions
	local mypos = self:GetPos()
	if 0 < numtrails then
		render.SetMaterial(matTrail)
	
		render.StartBeam(numtrails + 1)
			render.AddBeam(mypos, 24, 0.5, COLOR_CYAN)
			for i=1, #self.TrailPositions do
				render.AddBeam(self.TrailPositions[i], math.max(0, 24 - i * 0.25), i + 0.5, COLOR_CYAN)
			end
		render.EndBeam()

		render.StartBeam(#self.TrailPositions2 + 1)
			render.AddBeam(mypos, 16, 0.5, COLOR_CYAN)
			for i=1, #self.TrailPositions2 do
				render.AddBeam(self.TrailPositions2[i], 16, i + 0.5, COLOR_CYAN)
			end
		render.EndBeam()
	end

	
	local particle = self.Emitter:Add("effects/spark", mypos + VectorRand():GetNormal() * 6)
	particle:SetVelocity(VectorRand():GetNormal() * 8)
	particle:SetDieTime(math.Rand(0.4, 0.8))
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(255)
	particle:SetStartSize(math.Rand(2, 4))
	particle:SetEndSize(0)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-20, 20))
	particle:SetColor(50, 100, 255)
	particle:SetAirResistance(10)
	if self:GetVelocity():Length() == 0 then
		particle:SetGravity(Vector(0, 0, 200))
	end
end
