ENT.Type = "anim"
ENT.Base = "status__base"

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.StartSound = Sound("nox/anchoron.ogg")
ENT.EndSound = Sound("nox/anchoroff.ogg")
ENT.StatusImage = "spellicons/anchor.png"

function ENT:CanTeleport(owner)
	return false
end