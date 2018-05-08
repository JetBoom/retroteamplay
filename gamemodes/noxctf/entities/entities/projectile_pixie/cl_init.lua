include('shared.lua')

ENT.NextEmit = 0

function ENT:Initialize()
	self:SetMaterial("models/props_combine/stasisfield_beam")
	self:SetModelScale(10, 0)

	self.Col = team.GetColor(self:GetSkin()) or color_white

	self.AmbientSound = CreateSound(self, "npc/antlion/charge_loop1.wav")

end

function ENT:Think()
	self:SetModelScale(10, 0)
	self.AmbientSound:PlayEx(1,110)
end

function ENT:OnRemove()
	self.AmbientSound:Stop()
end

local matGlow = Material("sprites/light_glow02_add")

function ENT:Draw()
	local vOffset = self:GetPos()
	local col = self.Col
	local r,g,b = col.r, col.g, col.b
	render.SetColorModulation(r / 255, g / 255, b / 255)
	render.SetBlend(0.4)
	render.SuppressEngineLighting(true)
	self:DrawModel()
	render.SuppressEngineLighting(false)
	render.SetColorModulation(1, 1, 1)
	render.SetBlend(1)
	
	for i=1,15 do
		render.SetMaterial(matGlow)
		render.DrawSprite(vOffset + VectorRand():GetNormal() * math.Rand(0,64), math.Rand(24, 34), math.Rand(24, 34), Color(255,255,50))
		render.DrawSprite(vOffset + VectorRand():GetNormal() * math.Rand(0,64), 40, 40, col)
	end

	if CurTime() > self.NextEmit then
		local emitter = ParticleEmitter(self:GetPos())
		emitter:SetNearClip(28, 34)
		for i=1, 7 do
			local particle = emitter:Add("sprites/light_glow02_add", vOffset + VectorRand():GetNormal() * 36)
			particle:SetVelocity(VectorRand():GetNormal() * math.Rand(2, 8))
			particle:SetDieTime(1)
			particle:SetStartAlpha(255)
			particle:SetStartSize(math.Rand(12, 25))
			particle:SetEndSize(0)
			particle:SetColor(r, g, b)
			particle:SetRoll(math.Rand(0, 359))
			particle:SetRollDelta(math.Rand(-2, 2))
			particle:SetAirResistance(30)
			particle:SetCollide(true)
			particle:SetBounce(0.5)
		end
		emitter:Finish()
		self.NextEmit = CurTime() + 0.1
	end
end
