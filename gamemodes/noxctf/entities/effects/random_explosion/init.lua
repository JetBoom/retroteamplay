function EFFECT:Init(data)
	local Pos = data:GetOrigin() + Vector(0,0,2)

	sound.Play("ambient/explosions/explode_8.wav", Pos, 99, math.random(95, 105))
	sound.Play("nox/explosion0"..math.random(3, 5)..".ogg", Pos, 99, math.random(95, 105))

	local emitter = ParticleEmitter(Pos)
	emitter:SetNearClip(24, 32)
		for i=1, 16 do
			local particle = emitter:Add("particles/flamelet2", Pos + Vector(math.random(-80,80),math.random(-80,80),math.random(0,180)))
			particle:SetVelocity(Vector(math.random(-60,160),math.random(-60,160),math.random(150,400)) * 0.5)
			particle:SetDieTime(math.random(2, 3) * 0.5)
			particle:SetStartAlpha(math.random(220, 240))
			particle:SetStartSize(48 * 0.5)
			particle:SetEndSize(math.random(260, 292) * 0.5)
			particle:SetRoll(math.random(360, 480))
			particle:SetRollDelta(math.Rand(-1, 1))
			particle:SetColor(50, math.random(60, 80), math.random(220, 255))
		end

		for i=1, math.max(1, EFFECT_QUALITY * 2.5) do
			local particle = emitter:Add("particles/smokey", Pos + Vector(math.Rand(-40, 40), math.Rand(-40, 40), math.Rand(0, 150)))
			particle:SetVelocity(Vector(math.Rand(-1, 1), math.Rand(-1, 1), math.Rand(0, 0.5)):GetNormal() * math.Rand(16, 72))
			particle:SetDieTime(math.Rand(5.9, 6.8))
			particle:SetStartAlpha(math.Rand(205, 255))
			particle:SetStartSize(math.Rand(42, 68))
			particle:SetEndSize(math.Rand(192, 256))
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-2.5, 2.5))
			particle:SetColor(70, 60, 60)
		end

		for i=1, 8 do
			local particle = emitter:Add("particles/flamelet1", Pos + Vector(math.random(-40,40),math.random(-40,40),math.random(-30,150)))
			particle:SetVelocity(Vector(math.random(-120,150),math.random(-120,150),math.random(170,270)) * 0.5)
			particle:SetDieTime(math.random(2, 3) * 0.5)
			particle:SetStartAlpha(math.random(220, 240))
			particle:SetStartSize(16)
			particle:SetEndSize(math.Rand(228, 260) * 0.5)
			particle:SetRoll(math.Rand(360, 480))
			particle:SetRollDelta(math.Rand(-1, 1))
			particle:SetColor(50, math.random(50, 125), math.random(170, 255))

			local particle = emitter:Add("particles/flamelet1", Pos + Vector(math.random(-30,30),math.random(-30,30),math.random(-40,50)))
			particle:SetVelocity(Vector(math.random(-60,60),math.random(-60,60),math.random(30,70)) * 0.5)
			particle:SetDieTime(math.random(2, 3) * 0.5)
			particle:SetStartAlpha(math.random(220, 240))
			particle:SetStartSize(16)
			particle:SetEndSize(math.random(228, 260) * 0.5)
			particle:SetRoll(math.random(360, 480))
			particle:SetRollDelta(math.Rand(-1, 1))
			particle:SetColor(50, math.random(50, 125), math.random(170, 255))
		end

		for i=1, math.max(4, EFFECT_QUALITY * 6) do
			local particle = emitter:Add("particles/flamelet3", Pos + Vector(math.random(-40,40),math.random(-40,40),math.random(10,170)))
			particle:SetVelocity(Vector(math.random(-200,200),math.random(-200,200),math.random(-20,180)) * 0.5)
			particle:SetDieTime(math.random(2, 3) * 0.5)
			particle:SetStartAlpha(math.random(220, 240))
			particle:SetStartSize(48* 0.5)
			particle:SetEndSize(math.random(168, 190) * 0.5)
			particle:SetRoll(math.random(360,480))
			particle:SetRollDelta(math.Rand(-1, 1))
			particle:SetColor(50, math.random(50, 125), math.random(170, 255))
		end

		for i=1, math.max(4, EFFECT_QUALITY * 3.5) do
			local particle = emitter:Add("particles/flamelet1", Pos + Vector(math.random(-40,40),math.random(-40,40),math.random(-30,10)))
			particle:SetVelocity(Vector(math.random(-180,180),math.random(-180,180),math.random(0,110)) * 0.5)
			particle:SetDieTime(math.random(1, 2) * 0.5)
			particle:SetStartAlpha(math.random(205, 255))
			particle:SetStartSize(math.random(42, 68) * 0.5)
			particle:SetEndSize(math.random(192, 256) * 0.5)
			particle:SetRoll(math.random(360, 480))
			particle:SetRollDelta(math.Rand(-1, 1))
			particle:SetColor(50, math.random(60, 80), math.random(170, 255))

			local particle = emitter:Add("particles/flamelet1", Pos + Vector(math.random(-40,40),math.random(-40,50),math.random(20,280)))
			particle:SetVelocity(Vector(math.random(-180,180),math.random(-180,180),math.random(160,240)) * 0.5)
			particle:SetDieTime(math.random(2, 3) * 0.5)
			particle:SetStartAlpha(math.random(60, 80))
			particle:SetStartSize(math.random(32, 48) * 0.5)
			particle:SetEndSize(math.random(192, 256) * 0.5)
			particle:SetRoll(math.random(480, 540))
			particle:SetRollDelta(math.Rand(-1, 1))
			particle:SetColor(50, math.random(60, 80), math.random(170, 255))

			local particle = emitter:Add("particles/flamelet1", Pos + Vector(math.random(-40,40),math.random(-40,50),math.random(20,280)))
			particle:SetVelocity(Vector(math.random(-180,280),math.random(-180,280),math.random(160,240)) * 0.5)
			particle:SetDieTime(math.Rand(1, 2))
			particle:SetStartAlpha(math.random(140, 160))
			particle:SetStartSize(math.random(32, 48) * 0.5)
			particle:SetEndSize(math.random(192, 256) * 0.5)
			particle:SetRoll(math.random(480, 540))
			particle:SetRollDelta(math.random(-1, 1))
			particle:SetColor(170, 170, 170)

			local particle = emitter:Add("particles/flamelet1", Pos + Vector(math.random(-200,200),math.random(-200,200),math.random(5,10)))
			particle:SetVelocity(Vector(math.random(-200,200),math.random(-200,200),math.random(120,200)) * 0.5)
			particle:SetDieTime(math.random(2, 3) * 0.5)
			particle:SetStartAlpha(math.random(200, 255))
			particle:SetStartSize(math.random(42, 68) * 0.5)
			particle:SetEndSize(math.random(192, 256) * 0.5)
			particle:SetRoll(math.random(480, 540))
			particle:SetRollDelta(math.random(-1, 1))
			particle:SetColor(170, 170, 170)
		end
	emitter:Finish()

	for i=1, math.Rand(3, 5) * math.max(0.5, EFFECT_QUALITY) do
		local effectdata = EffectData()
			effectdata:SetOrigin(Pos + VectorRand() * 8)
			effectdata:SetNormal(VectorRand())
			effectdata:SetScale(500)
		util.Effect("ember", effectdata)
	end

	ExplosiveEffect(Pos, 240, 110, DMGTYPE_FIRE)

	local tr = util.TraceLine({start = Pos, endpos = Pos + Vector(0,0,-64)})
	util.Decal("Scorch", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
end

function EFFECT:Think() return false end
function EFFECT:Render() end
