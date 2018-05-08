ENT.Type = "anim"
ENT.Base = "status__base"
ENT.Hostile = true

ENT.StartSound = {sound = Sound("physics/concrete/concrete_break"..math.random(2,3)..".wav"), vol = 77, pitchLB = 90, pitchRB = 95}
ENT.StatusImage = "spellicons/aurify.png"

function ENT:PlayerCantCastSpell(pl, spellid)
	pl:LM(88)
	return true
end
