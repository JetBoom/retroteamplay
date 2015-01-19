ENT.Type = "anim"
ENT.Base = "status__base"
ENT.Hostile = true

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "BeamTarget")
end
