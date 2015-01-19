function EFFECT:Init(data)
	local pos = data:GetOrigin()

	sound.Play("nox/lightning_impact.ogg", pos, 100, 100)
	sound.Play("ambient/levels/labs/electric_explosion"..math.random(1,5)..".wav", pos, 100, 100)

	local effectdata = EffectData()
		effectdata:SetOrigin(pos)
		effectdata:SetStart(pos)
		effectdata:SetScale(70)
		effectdata:SetMagnitude(10)
		effectdata:SetRadius(10)
	util.Effect("ThumperDust", effectdata)
	util.Effect("cball_explode", effectdata)

	ExplosiveEffect(pos, 64, 20, DMGTYPE_LIGHTNING)
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
