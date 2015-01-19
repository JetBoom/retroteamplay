ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.ChargeTime = 10
ENT.MaxDamage = 125
ENT.DamageType = DMGTYPE_FIRE
ENT.AttachMultiplier = 3
ENT.MaxRadius = 125
ENT.VisibilityRadius = 500
ENT.Debuff = "manastun"
ENT.MaxDebuffDuration = 5
ENT.KillDamage = 5 -- minimum damage needed to destroy the bomb
ENT.DrainInterval = .2 -- if attached to an entity that uses mana, how frequently it drains mana
ENT.DrainAmount = 10
ENT.ObeliskDrainAmount = 2

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "Attach")
	self:NetworkVar("Vector", 0, "Normal")
end
