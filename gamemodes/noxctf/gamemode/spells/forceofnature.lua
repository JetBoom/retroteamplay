SPELL.Name = "Force of Nature"
SPELL.Description = "Call in to being a ghastly green ball of light that destroys all those foolish enough to cross it's path."
SPELL.Mana = 75
SPELL.Classes = {"Conjurer"}
SPELL.Words = "du ru zo"

SPELL.Icon = "spellicons/forceofnature.png"

SPELL.Inversable = nil
SPELL.Hostile = true

function SPELL.Cast(pl)
	timer.Create(pl:UniqueID().."DoFON", 1, 1, function() DoForceOfNature(pl, pl:UniqueID()) end)
	pl:Stun(1, true, true)

	local effectdata = EffectData()
		effectdata:SetEntity(pl)
		effectdata:SetOrigin(pl:EyePos())
		effectdata:SetMagnitude(pl:Team())
	util.Effect("forceofnaturestart", effectdata, true)

	pl:CustomGesture(ACT_SIGNAL_FORWARD)
end
GM:AddLifeStatusTimer("DoFON")