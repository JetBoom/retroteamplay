ENT.Type = "anim"
ENT.Base = "status__base"

function ENT:GetCharges()
	return self:GetDTInt(0)
end

function ENT:SetCharges(charges)
	self:SetDTInt(0, charges)
end

function ENT:PlayerCantCastSpell(pl, spellid)
	if spellid == NameToSpell["Hallowed Ground"] then return false end

	pl:LM(62)
	return true
end