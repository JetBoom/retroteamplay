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

local matBolt = Material("Effects/laser1")
function ENT:Draw()
	if self:GetBeamTarget():IsValid() and self:GetOwner():IsValid() then
		local startpos = self:GetOwner():LocalToWorld(self:GetOwner():OBBCenter())
		local targetpos = self:GetBeamTarget():LocalToWorld(self:GetBeamTarget():OBBCenter())
		local dir = (targetpos - startpos):GetNormal()

		local beampos = {}

		local pos
		for i=1, math.ceil(startpos:Distance(targetpos) / 40) do
			if pos then
				pos = pos + dir * 40 + VectorRand():GetNormal() * math.Rand(-8, 8)
			else
				pos = startpos
			end

			table.insert(beampos, pos)
		end

		if not beampos[1] then return end

		render.SetMaterial(matBolt)
		local scroll = CurTime() * 20
		render.StartBeam(#beampos + 1)
		for i, pos in ipairs(beampos) do
			render.AddBeam(pos, math.sin((CurTime() + i * 0.2) * 5) * 8 + 16, scroll, COLOR_YELLOW)
		end
		render.AddBeam(targetpos, 8, scroll, COLOR_YELLOW)
		render.EndBeam()
	end
end

