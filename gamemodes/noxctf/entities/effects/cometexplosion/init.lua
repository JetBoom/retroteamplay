function EFFECT:Init(data)
	local pos = data:GetOrigin() + Vector(0, 0, 16)

	sound.Play("nox/explosion0"..math.random(1,5)..".ogg", pos, 125, math.random(85, 110))

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(32, 48)
	self.Emitter = emitter
	for i=1, 359, 7 do
		local particle = emitter:Add("particle/snow", pos)
		local sini = math.sin(i)
		local cosi = math.cos(i)
		local veli=math.Rand(256,512)
		particle:SetVelocity(Vector(veli * sini, veli * cosi, 0))
		particle:SetDieTime(math.Rand(1.5, 2.5))
		particle:SetStartAlpha(220)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(64,80))
		particle:SetEndSize(2)
		particle:SetRoll(math.Rand(0, 359))
		particle:SetRollDelta(math.Rand(-2, 2))
		particle:SetAirResistance(45)
		particle:SetCollide(true)
		particle:SetBounce(0.1)
		for x=0, 2 do
			local particle = emitter:Add("particle/snow", pos)
			particle:SetVelocity(Vector(x * 160 * sini * math.Rand(0.9, 1.1), x * 160 * cosi * math.Rand(0.9, 1.1), 0))
			particle:SetDieTime(math.Rand(1.25, 1.5) + x * 0.33333)
			particle:SetStartAlpha(220)
			particle:SetEndAlpha(0)
			particle:SetStartSize(x * 2)
			particle:SetEndSize(x * math.Rand(20, 32))
			particle:SetRoll(math.Rand(0, 359))
			particle:SetRollDelta(math.Rand(-1 * x, x))
			particle:SetAirResistance(70)
			particle:SetCollide(true)
			particle:SetBounce(0.1)
			particle:SetColor(200 - x * 20, 200 - x * 20, 220 - x * 20)
		end
	end

	for i=1, 359, 12 do
		if 4 < math.random(1, 10) then
			local particle = emitter:Add("particle/snow", pos)
			particle:SetVelocity(Vector(180 * math.sin(i) * math.Rand(0.9, 1.1), 180 * math.cos(i) * math.Rand(0.9, 1.1), math.Rand(500, 720)))
			particle:SetDieTime(math.Rand(2.25, 3.5))
			particle:SetStartAlpha(220)
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.Rand(40, 68))
			particle:SetEndSize(1)
			particle:SetRoll(math.Rand(0, 359))
			particle:SetRollDelta(math.Rand(-3, 3))
			particle:SetAirResistance(50)
			particle:SetCollide(true)
			particle:SetBounce(0.3)
			particle:SetGravity(Vector(0,0,-600))
		else
			local particle = emitter:Add("particle/snow", pos)
			particle:SetVelocity(Vector(32 * math.sin(i) * math.Rand(0.9, 1.1), 32 * math.cos(i) * math.Rand(0.9, 1.1), math.Rand(75, 300)))
			particle:SetDieTime(math.Rand(2.25, 3.5))
			particle:SetStartAlpha(220)
			particle:SetEndAlpha(0)
			particle:SetStartSize(2)
			particle:SetEndSize(math.Rand(45, 88))
			particle:SetRoll(math.Rand(0, 359))
			particle:SetRollDelta(math.Rand(-3, 3))
			particle:SetAirResistance(40)
			particle:SetCollide(true)
			particle:SetBounce(0.1)
			particle:SetColor(128, 140, 180)
		end
	end

	ExplosiveEffect(pos, 176, 92, DMGTYPE_ICE)
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
