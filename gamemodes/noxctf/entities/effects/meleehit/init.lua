function EFFECT:Init(data)
	local vOffset = data:GetOrigin()
	local startpos = data:GetStart()
	local dir = startpos - vOffset
	local normal = dir:GetNormal()
	vOffset = vOffset + normal * 2

	sound.Play("nox/meleehit_blunt01.ogg", vOffset, 76, math.Rand(100, 110))

	local emitter = ParticleEmitter(vOffset)
	emitter:SetNearClip(20, 30)
	for i=1, 46 do
		local particle = emitter:Add("effects/spark", vOffset + dir * math.Rand(-3, 3))
		local vel = VectorRand() * 250 + normal * math.Rand(-500,500)
		particle:SetVelocity(vel)
		particle:SetDieTime(math.Rand(0.5, 0.8)) 
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(1, 3))
		particle:SetEndSize(1)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-5, 5))
		particle:SetAngles(vel:Angle())
	end

	local particle = emitter:Add("effects/yellowflare", vOffset)
	particle:SetDieTime(0.1)
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(100)
	particle:SetStartSize(10)
	particle:SetEndSize(160)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetGravity(Vector(0, 0, 10))

	local particle = emitter:Add("effects/yellowflare", vOffset)
	particle:SetDieTime(0.25)
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(100)
	particle:SetStartSize(10)
	particle:SetEndSize(160)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetGravity(Vector(0, 0, 10))

	local particle = emitter:Add("effects/yellowflare", vOffset)
	particle:SetDieTime(0.2)
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(0)
	particle:SetStartSize(20)
	particle:SetEndSize(240)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetGravity(Vector(0, 0, 10))
	particle:SetColor(255, 30, 0)

	emitter:Finish()

	ExplosiveEffect(vOffset, 64, 64, DMGTYPE_PHYSICAL)
end

function EFFECT:Think()
	return false
end
   
function EFFECT:Render()
end 
