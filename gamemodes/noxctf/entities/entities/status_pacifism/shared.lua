ENT.Type = "anim"
ENT.Base = "status__base"

function ENT:PlayerCantAttack(pl, wep)
	if SERVER then
		pl:LM(83)
	end
	return true
end
