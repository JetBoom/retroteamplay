ENT.Type = "anim"
ENT.Base = "status__base"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.Animation = "EARTHQUAKE2"

ENT.StatusImage = "spellicons/earthquake.png"

ENT.Radius = 600
ENT.QuakeInterval = .75
ENT.QuakeDamage = 10
ENT.XYVel = 250 -- intensity of x and y plane velocity each tick
ENT.ZVel = 200 -- intensity of vertical velocity each tick
ENT.DMGType = DMGTYPE_PHYSICAL

function ENT:PlayerCantCastSpell(pl, spellid)
	pl:LM(62)
	return true
end