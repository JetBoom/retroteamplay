// Source Forts compatability
ENT.Type = "brush"

function ENT:Initialize()
end

function ENT:Think()
end

function ENT:StartTouch(ent)
end

function ENT:EndTouch(ent)
end

function ENT:Touch(ent)
	if ent:IsPlayer() and ent:Alive() then
		ent:TakeSpecialDamage(999, DMGTYPE_FIRE, NULL, NULL)
	end
end
