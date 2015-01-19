ENT.Type = "anim"
ENT.Base = "status__base"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.Animation = "VOLCANICBLAST"

ENT.DisableJump = true

ENT.StatusImage = "spellicons/volcanicblast.png"

function ENT:PlayerCantCastSpell(pl, spellid)
	pl:LM(62)
	return true
end