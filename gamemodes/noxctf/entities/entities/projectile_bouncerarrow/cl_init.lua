include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
	self.TrailPositions = {}
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(30, 40)
	self.NextEmit = 0
	self.Col = self:GetColor()
end

function ENT:Think()
	self.Emitter:SetPos(self:GetPos())
	if 0 < self:GetVelocity():Length() then
		table.insert(self.TrailPositions, 1, self:GetPos())
		if self.TrailPositions[18] then
			table.remove(self.TrailPositions, 18)
		end
		self:SetRenderBoundsWS(self.TrailPositions[#self.TrailPositions], self:GetPos() + self:GetForward() * 8, Vector(32, 32, 32))
	elseif self.TrailPositions[1] then
		table.remove(self.TrailPositions, #self.TrailPositions)
	end
end

function ENT:OnRemove()
	--self.Emitter:Finish()
end

local matTrail = Material("Effects/laser1")
function ENT:DrawTranslucent()
	self:DrawModel()

	render.SetMaterial(matTrail)
	render.StartBeam(#self.TrailPositions + 1)
		local col = self.Col
		render.AddBeam(self:GetPos(), 18, 1, col)
		for i=1, #self.TrailPositions do
			render.AddBeam(self.TrailPositions[i], 18 - i * 0.98, i + 1, col)
		end
	render.EndBeam()

	if self.NextEmit <= RealTime() then
		self.NextEmit = RealTime() + 0.01 + EFFECT_IQUALITY * 0.01

		local particle = self.Emitter:Add("sprites/glow04_noz", self:GetPos() + VectorRand() * 2)
		particle:SetDieTime(0.75)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(16)
		particle:SetEndSize(16)
		particle:SetColor(255, 255, 0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-20, 20))
		particle:SetAirResistance(20)
		if self:GetVelocity():Length() == 0 then
			particle:SetGravity(Vector(0, 0, 200))
		else
			particle:SetGravity(Vector(0, 0, 0))
		end
	end
end
