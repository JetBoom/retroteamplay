local function CreateParticlesAt(posa, emitter, velocity)
	for i=1, 2 do
		particle = emitter:Add("sprites/light_glow02_add", posa + VectorRand() * 3)
		particle:SetVelocity(velocity) // * math.Rand(0.8, 1.2))
		particle:SetDieTime(math.Rand(1.25, 1.6))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(250)
		particle:SetStartSize(math.random(12, 15))
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(-0.8, 0.8))
		particle:SetColor(0, 100, 255)
		particle:SetAirResistance(200)

		particle = emitter:Add("effects/spark", posa + VectorRand() * 3)
		particle:SetVelocity(velocity) //* math.Rand(0.8, 1.2))
		particle:SetDieTime(math.Rand(1, 1.25))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(100)
		particle:SetStartSize(math.random(6, 7))
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(-0.8, 0.8))
		particle:SetColor(0, 50, 255)
		particle:SetAirResistance(200)
	end
end

function EFFECT:Init(data)
	if EFFECT_QUALITY < 2 then return end

	local ent = data:GetEntity()
	if not ent:IsValid() then return end

	local pos = data:GetOrigin()
	local vel = data:GetNormal() * 750

	sound.Play("nox/blink.ogg", pos, 90, math.random(95, 105))

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)
	for i=0, 25 do
		local bone = ent:GetBoneMatrix(i)
		if bone then
			CreateParticlesAt(bone:GetTranslation(), emitter, vel)
		end
	end
	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
