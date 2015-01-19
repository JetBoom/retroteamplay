include("shared.lua")

function ENT:Initialize()
	self.AmbientSound = CreateSound(self, "ambient/machines/electric_machine.wav")
end

function ENT:Think()
	if self:IsOpaque() then
		self.AmbientSound:PlayEx(0.7, 100 + math.sin(CurTime()))
	end
end

function ENT:OnRemove()
	self.AmbientSound:Stop()
end

local matBolt = Material("Effects/laser1")
local matGlow = Material("sprites/glow04_noz")
function ENT:Draw()
	self:DrawModel()

	local c = self:GetColor()
	if c.a < 255 then return end

	render.SetMaterial(matBolt)

	local rt = RealTime()
	local orbpos = self:GetPos() + self:GetUp() * 100
	local right = self:GetRight()
	local leftpos = orbpos + right * -85
	local rightpos = orbpos + right * 85

	local BeamPos = {}
	local pos
	local dir = (rightpos - leftpos):GetNormal()
	for i=1, math.ceil(leftpos:Distance(orbpos) / 20) do
		if pos then
			pos = pos + dir * 20 + VectorRand() * 5
		else
			pos = leftpos
		end
		BeamPos[#BeamPos + 1] = pos
	end

	local scroll = rt * 20
	render.StartBeam(#BeamPos)
	for i, pos in ipairs(BeamPos) do
		render.AddBeam(pos, math.sin((rt + i * 0.2) * 5) * 48 + 92, scroll, color_white)
	end
	render.EndBeam()

	local BeamPos = {}
	local pos
	dir = dir * -1
	for i=1, math.ceil(rightpos:Distance(orbpos) / 20) do
		if pos then
			pos = pos + dir * 20 + VectorRand() * 5
		else
			pos = rightpos
		end
		BeamPos[#BeamPos + 1] = pos
	end

	local scroll = rt * 20
	render.StartBeam(#BeamPos)
	for i, pos in ipairs(BeamPos) do
		render.AddBeam(pos, math.sin((rt + i * 0.2) * 5) * 48 + 92, scroll, color_white)
	end
	render.EndBeam()

	render.SetMaterial(matGlow)
	local spritesize = 180 + math.cos(rt * 10) * 48
	render.DrawSprite(orbpos, spritesize, spritesize, color_white)
	render.DrawSprite(orbpos, 128, 128, COLOR_CYAN)
end
