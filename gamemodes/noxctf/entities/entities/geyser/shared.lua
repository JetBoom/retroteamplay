ENT.Type = "anim"

ENT.Radius = 60
ENT.Damage = 30
ENT.EruptTime = .3
ENT.DeathTime = 1.2

function ENT:SetupDataTables()
	self:NetworkVar("Float", 0, "EruptTime")
end