include("shared.lua")

function ENT:Initialize()
	self.TrailPositions = {}
	local c = self:GetColor()
	self.Col = Color(c.r, c.g, c.b, c.a)
end

function ENT:Think()
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

local matTrail = Material("Effects/laser1")
function ENT:DrawTranslucent()
	self:DrawModel()

	render.SetMaterial(matTrail)
	render.StartBeam(#self.TrailPositions + 1)
		local col = self.Col
		render.AddBeam(self:GetPos(), 8, 1, col)
		for i=1, #self.TrailPositions do
			render.AddBeam(self.TrailPositions[i], 8 - i * 0.4, i + 1, col)
		end
	render.EndBeam()
end
