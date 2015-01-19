ENT.Type = "anim"
ENT.Base = "status__base"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.Animation = "HYDROPUMP"

ENT.StatusImage = "spellicons/hydropump.png"

ENT.TickInterval = .2
ENT.ManaPerTick = 4
ENT.MinDamage = 1
ENT.MaxDamage = 5
ENT.Range = 800
ENT.Force = 550 -- scales based on distance
ENT.ProjTravelTime = 1/2

function ENT:PlayerCantCastSpell(pl, spellid)
	pl:LM(62)
	return true
end