function EFFECT:Init(data)
	local target = data:GetEntity()

	if not target:IsPlayer() then
		return
	end

	if MySelf == target then
		DelayIcons[ NameToSpell["Invisibility"] ] = nil
	end

	target:EmitSound("nox/invisoff.ogg")

	if EFFECT_QUALITY < 1 then return end

	self.StartTime = CurTime()
	self.Entity:SetPos(data:GetEntity():GetPos() + Vector(0, 0, 60))

	local col = team.GetColor(target:Team())
	target:SetColor(Color(col.r, col.g, col.b, 255))

	if render.GetDXLevel() < 90 then return end

	local emitter = ParticleEmitter(self.Entity:GetPos())
	for i=0, 2 do
		local particle = emitter:Add("sprites/heatwave", self.Entity:GetPos() + (VectorRand() * 16) + Vector(0, 0, math.Rand(-16, -72)))
		particle:SetVelocity(VectorRand() * math.random(2, 4) + Vector(0, 0, math.Rand(32, 64)) + (target:GetVelocity() / 3))
		particle:SetDieTime(1)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(24)
		particle:SetEndSize(2)
		particle:SetColor(255, 255, 255)
	end
	for i=0, 1 do
		local particle = emitter:Add("sprites/heatwave", self.Entity:GetPos() + (VectorRand() * 8) + Vector(0,0,math.Rand(-16, -72)))
		particle:SetVelocity(Vector(0, 0, math.Rand(32, 64)) + (target:GetVelocity() / 3))
		particle:SetDieTime(0.5)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(12)
		particle:SetEndSize(2)
		particle:SetColor(255, 255, 255)
	end
	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
