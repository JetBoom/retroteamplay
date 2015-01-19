include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
	self.TrailPositions = {}
	self.Col = self:GetColor()
end

function ENT:Think()
	if 0 < self:GetVelocity():Length() then
		table.insert(self.TrailPositions, 1, self:GetPos())
		if self.TrailPositions[32] then
			table.remove(self.TrailPositions, 32)
		end
		self:SetRenderBoundsWS(self.TrailPositions[#self.TrailPositions], self:GetPos() + self:GetForward() * 8, Vector(32, 32, 32))
	elseif self.TrailPositions[1] then
		table.remove(self.TrailPositions, #self.TrailPositions)
	end
end

function ENT:OnRemove()
end

local matTrail = Material("Effects/laser1")
function ENT:DrawTranslucent()
	self:DrawModel()

	render.SetMaterial(matTrail)
	render.StartBeam(#self.TrailPositions + 1)
		local col = self.Col
		render.AddBeam(self:GetPos(), 12, 1, col)
		for i=1, #self.TrailPositions do
			render.AddBeam(self.TrailPositions[i], 12 - i * 0.5, i + 1, col)
		end
	render.EndBeam()
end
