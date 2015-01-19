EFFECT.Size = 0.1

function EFFECT:Init(data)
	local pos = data:GetOrigin()
	local dir = data:GetNormal()
	sound.Play("physics/glass/glass_largesheet_break3.wav", pos, 80, math.random(85, 110))

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)
	for i=1, math.max(3, EFFECT_QUALITY * 4) do
		local particle = emitter:Add("particle/snow", pos)
		particle:SetVelocity(VectorRand():GetNormal() * math.Rand(32, 48))
		particle:SetDieTime(math.Rand(2.2, 2.6))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(16)
		particle:SetEndSize(1)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-1, 1))
		particle:SetCollide(true)
		particle:SetBounce(0.2)
		particle:SetAirResistance(50)

		local particle = emitter:Add("particles/balloon_bit", pos + dir * -i * 10 )
		particle:SetVelocity(VectorRand():GetNormal() * math.Rand(40, 50))
		particle:SetDieTime(math.Rand(2.2, 2.5))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(4)
		particle:SetEndSize(1)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-1, 1))
		particle:SetCollide(true)
		particle:SetBounce(0.2)
		particle:SetAirResistance(50)
		particle:SetGravity(Vector(0,0,-300))
	end
	emitter:Finish()

	self.Entity:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
	self.Entity:SetRenderBoundsWS(pos + Vector(-100, -100, -100), pos + Vector(100, 100, 100))
	self.Entity:SetMaterial("models/shiny")
	--self.Entity:SetAngles(VectorRand():Angle())

	ExplosiveEffect(pos, 32, 20, DMGTYPE_ICE)
end

function EFFECT:Think()
	local ft = FrameTime()
	self.Size = self.Size + ft * self.Size * 7
	return self.Size < 3
end

function EFFECT:Render()
	local ent = self.Entity
	local siz = self.Size * 0.3
	
	ent:SetModelScale(siz, 0)
	ent:SetColor(Color(240, 240, 255, siz * 100))
	ent:DrawModel()
end
