local function CreateParticlesAt(posa, emitter)
	for i=1, EFFECT_QUALITY * 2 do
		particle = emitter:Add("effects/fire_cloud"..math.random(1,2), posa + VectorRand() * 7)
--		particle:SetVelocity(Vector(1,1,1) * math.Rand(200,300))
		particle:SetDieTime(1.5)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(255)
		particle:SetStartSize(math.random(8, 10))
		particle:SetEndSize(7)
		particle:SetRoll(math.Rand(-0.8, 0.8))
		particle:SetColor(0, 255, 0)
		particle:SetAirResistance(10)
		particle:SetBounce(0.3)
		particle:SetCollide(true)
		timer.Simple(1, function() particle.SetGravity(particle, Vector(0,0,-100)) end)
		for p=1,2 do
		particle = emitter:Add("sprites/light_glow02_add", posa + VectorRand() * 4)
		particle:SetVelocity(Vector(math.Rand(-200,400), math.Rand(-200,400), math.Rand(-200,200)))
		particle:SetDieTime(0.9)
		particle:SetStartAlpha(180)
		particle:SetEndAlpha(100)
		particle:SetStartSize(math.Rand(16, 24))
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(-0.8, 0.8))
		particle:SetColor(0, 180, 0)
		particle:SetAirResistance(10)
		particle:SetBounce(0.3)
		particle:SetCollide(true)
		particle:SetGravity(Vector(0,0,-400 + 50*p))
		end
	end
end

function EFFECT:Init(data)
	local ent = data:GetEntity()
	if not ent:IsValid() then return end
	ent:EmitSound("ambient/machines/steam_release_2.wav")

	if EFFECT_QUALITY < 1 then return end
	
	local pos = data:GetOrigin()

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(40, 60)
	for i=0, 6 do
		local bone = ent:GetBoneMatrix(i)
		if bone then
			CreateParticlesAt(bone:GetTranslation(), emitter)
		end
	end
	for i=0, 3 do
		particle = emitter:Add("particle/smokestack", pos)
		particle:SetVelocity(Vector(math.Rand(-100,100), math.Rand(-100,100), math.Rand(-50,100)))
		particle:SetDieTime(math.Rand(1, 1.4))
		particle:SetStartAlpha(254)
		particle:SetEndAlpha(0)
		particle:SetStartSize(16)
		particle:SetEndSize(30)
		particle:SetColor(30, 255, 20)
		particle:SetRoll(math.Rand(0, 359))
		particle:SetRollDelta(math.Rand(-4, 4))
		particle:SetGravity(Vector(0,0,-10))
		particle:SetAirResistance(300)
	end
	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end

