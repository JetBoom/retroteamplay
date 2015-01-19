ENT.Type = "anim"
ENT.Base = "status__base"
ENT.Animation = "DRAGONBLOOD"

ENT.TickInterval = .2
ENT.ManaPerTick = 4

function ENT:PlaySound(owner, name)
	if name == "Start" then
		owner:EmitSound("nox/heal.ogg", 90, 70)
	end
end