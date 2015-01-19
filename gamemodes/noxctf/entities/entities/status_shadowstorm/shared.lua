ENT.Type = "anim"
ENT.Base = "status__base"

ENT.StatusImage = "spellicons/shadowstorm.png"

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "Ent")
end

function ENT:StatusImmunity(status)
	return status.Hostile
end

function ENT:ShouldRemainInvisible()
	return true
end