ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.IsCapacitor = true
ENT.CanTakeMana = true
ENT.NoTranslocate = true

function ENT:SetupDataTables()
	self:NetworkVar( "Int", 0, "Mana" );
end