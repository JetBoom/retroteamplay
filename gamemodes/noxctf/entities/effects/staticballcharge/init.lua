local matBolt = Material("Effects/laser1")

function EFFECT:Init(data)
	self.DieTime = RealTime() + 0.3
	self.EndPos = data:GetStart()
	self.BeamPos = {}

	local startpos = data:GetOrigin()
	local endpos = self.EndPos
	local emitter = ParticleEmitter(endpos)
		for i=1, 20 do
			local particle = emitter:Add("sprites/light_glow02_add", endpos + VectorRand() * 16)
			particle:SetVelocity(VectorRand() * 64 + Vector(0,0,190))
			particle:SetDieTime(1)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(50)
			particle:SetStartSize(14)
			particle:SetEndSize(2)
			particle:SetRoll(math.Rand(-0.8, 0.8))
			particle:SetColor(0, 100, 255)
			particle:SetCollide(true)
			particle:SetBounce(0.75)
			particle:SetGravity(Vector(0,0,-600))
			particle:SetAirResistance(40)
		end
	emitter:Finish()

	local pos = nil
	for i=1, math.ceil(startpos:Distance(endpos) / 32) do
		if pos then
			pos = pos + (endpos - pos):GetNormal() * 32 + VectorRand() * 6
		else
			pos = startpos
		end
		table.insert(self.BeamPos, pos)
	end

	sound.Play("DoSpark", endpos, 90, math.random(95, 105))

	/*local dlight = DynamicLight(math.random(1, 999999))
	if dlight then
		dlight.Pos = endpos
		dlight.r = 0
		dlight.g = 110
		dlight.b = 255
		dlight.Brightness = 7
		dlight.Decay = 50
		dlight.Size = 100
		dlight.DieTime = CurTime() + 0.3
	end*/
end

function EFFECT:Think()
	self.Entity:SetPos(MySelf:GetShootPos() + MySelf:GetAimVector() * 8)
	return RealTime() < self.DieTime
end

function EFFECT:Render()
	render.SetMaterial(matBolt)
	for i, pos in ipairs(self.BeamPos) do
		if self.BeamPos[i + 1] then
			render.DrawBeam(pos, self.BeamPos[i + 1], 16, 13, 13, COLOR_BLUE)
			render.DrawBeam(pos, self.EndPos, 12, 13, 13, COLOR_CYAN)
		end
	end
end
