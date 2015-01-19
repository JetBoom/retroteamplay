ENT.Type = "anim"
ENT.Base = "status__base"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.Animation = "ERUPTION"

ENT.StatusImage = "spellicons/meteorshards.png"

ENT.ProjectileSpeed = 600
ENT.Radius = 1000

function ENT:PlayerCantCastSpell(pl, spellid)
	pl:LM(62)
	return true
end