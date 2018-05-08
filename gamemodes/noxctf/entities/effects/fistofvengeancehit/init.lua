function EFFECT:Init(data)
	local pos = data:GetOrigin() + Vector(0, 0, 16)

	local tr = util.TraceLine({start = pos, endpos = pos + Vector(0, 0, -90)})
	util.Decal("Scorch", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)

	sound.Play("npc/env_headcrabcanister/explosion.wav", pos, 80, 80)

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(32, 48)
	self.Emitter = emitter
	for i=1, 359, 7 do
		local particle = emitter:Add("particles/smokey", pos)
		local sini = math.sin(i)
		local cosi = math.cos(i)
		particle:SetVelocity(Vector(1500 * sini, 1500 * cosi, 0))
		particle:SetDieTime(0.75)
		particle:SetStartAlpha(220)
		particle:SetEndAlpha(0)
		particle:SetStartSize(72)
		particle:SetEndSize(2)
		particle:SetRoll(math.Rand(0, 359))
		particle:SetRollDelta(math.Rand(-2, 2))
		particle:SetCollide(true)
		particle:SetBounce(0.1)
		particle:SetColor(190,170,170)
	end
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
