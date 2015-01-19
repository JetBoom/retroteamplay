ENT.Type = "anim"
ENT.Base = "status__base"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.Hostile = true

ENT.StartSound = Sound("nox/tagon.ogg")
ENT.EndSound = Sound("nox/tagoff.ogg")
ENT.StatusImage = "spellicons/tag.png"

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "TagOwner")
end