ENT.Type = "anim"
ENT.Base = "status__base"
ENT.Animation = "longsword_defensive"

function ENT:PlaySound(owner, name)
	if name == "Start" then
		owner:EmitSound("npc/metropolice/gear"..math.random(1,6)..".wav", 65, math.Rand(95, 105))
	end
end