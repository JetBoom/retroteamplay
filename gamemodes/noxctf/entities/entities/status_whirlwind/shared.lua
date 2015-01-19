ENT.Type = "anim"
ENT.Base = "status__base"
ENT.Animation = "WHIRLWIND"

ENT.DisableJump = true

ENT.StatusImage = "spellicons/whirlwind.png"

ENT.Speed = 500
ENT.Damage = 25

function ENT:SetupDataTables()
	self:NetworkVar("Vector", 0, "Dir")
end

function ENT:PlayerCantCastSpell(pl, spellid)
	return spellid ~= NameToSpell["Whirlwind"]
end