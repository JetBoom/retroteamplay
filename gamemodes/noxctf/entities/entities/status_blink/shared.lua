ENT.Type = "anim"
ENT.Base = "status__base"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.StartSound = Sound("ambient/energy/whiteflash.wav")
ENT.StatusImage = "spellicons/blink.png"

function ENT:PlayerCantCastSpell(pl, spellid)
	pl:LM(77)
	return true
end