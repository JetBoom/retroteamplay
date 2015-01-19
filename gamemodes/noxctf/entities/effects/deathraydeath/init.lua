util.PrecacheSound("npc/assassin/ball_zap1.wav")

local function CreateParticlesAt(posa, emitter)
	for i=1, 6 do
		local particle = emitter:Add("sprites/light_glow02_add", posa + VectorRand() * 7)
		particle:SetVelocity(Vector())
		particle:SetDieTime(math.Rand(6.5, 7.0))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(100)
		particle:SetStartSize(math.Rand(6, 7))
		particle:SetEndSize(5)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-0.8, 0.8))
		particle:SetColor(255, 0, 255)
		particle:SetAirResistance(10)
		particle:SetBounce(0.3)
		particle:SetCollide(true)
		timer.Simple(0.9, function() particle.SetGravity(particle, Vector(0, 0, -200)) end)
	end

	for i=1, 18 do
		local particle = emitter:Add("particle/smokestack", posa + VectorRand() * 4)
		particle:SetVelocity(Vector())
		particle:SetDieTime(math.Rand(6.5, 7.0))
		particle:SetStartAlpha(180)
		particle:SetEndAlpha(180)
		particle:SetStartSize(math.random(1, 2))
		particle:SetEndSize(1)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-0.8, 0.8))
		particle:SetColor(0, 0, 0)
		particle:SetAirResistance(10)
		particle:SetBounce(0.3)
		particle:SetCollide(true)
		timer.Simple(0.9, function() particle.SetGravity(particle, Vector(0, 0, -200)) end)
	end
end

function EFFECT:Init(data)
	local ent = data:GetEntity()
	if not ent:IsValid() then return end

	ent:EmitSound("nox/pdiedray.ogg")

	local pos = ent:GetPos() + Vector(0,0,4)

	local tr = util.TraceLine({start = pos, endpos = pos + Vector(0,0,-64), mask = MASK_SOLID})
	util.Decal("Rollermine.Crater", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(40, 60)
	for i=0, 25 do
		local bone = ent:GetBoneMatrix(i)
		if bone then
			CreateParticlesAt(bone:GetTranslation(), emitter)
		end
	end
	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
