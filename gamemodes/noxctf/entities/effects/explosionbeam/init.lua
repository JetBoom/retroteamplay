local matBolt = Material("effects/laser1")
local cBeam = Color(255, 200, 30)

function EFFECT:Init(data)
	self.DieTime = RealTime() + 0.75
	self.EndPos = data:GetOrigin()
	self.BeamPos = {}
	self.Scale = data:GetScale()
	self.Magnitude = data:GetMagnitude()

	local startpos = data:GetStart()
	local endpos = self.EndPos

	local pos = nil
	for i=1, math.ceil(startpos:Distance(endpos) / 32) do
		if pos then
			pos = pos + (endpos - pos):GetNormalized() * 32 + VectorRand() * 16
		else
			pos = startpos
		end
		table.insert(self.BeamPos, pos)
	end

	sound.Play("nox/sunburst_explode.ogg", endpos, 90, math.Rand(95, 105))
	self.Entity:SetRenderBoundsWS(startpos, endpos, Vector(32, 32, 32))
end

function EFFECT:Think()
	if RealTime() >= self.DieTime then
		local effectdata = EffectData()
			effectdata:SetOrigin(self.EndPos)
			effectdata:SetScale(self.Scale)
			effectdata:SetMagnitude(self.Magnitude)
		util.Effect("random_explosion2", effectdata)

		sound.Play("ambient/explosions/explode_"..math.random(7,8)..".wav", self.EndPos, 85, math.Rand(96, 104))

		return false
	end

	return true
end

function EFFECT:Render()
	if self.DieTime - RealTime() > 0.5 then
		render.SetMaterial(matBolt)
		for i, pos in ipairs(self.BeamPos) do
			if self.BeamPos[i+1] then
				render.DrawBeam(pos, self.BeamPos[i+1], 24, 28, 28, cBeam)
			end
		end
	end
end
