ENT.Type = "anim"
ENT.Base = "status__base"
ENT.Animation = "HEATDEATH"

ENT.DisableJump = true

ENT.StatusImage = "spellicons/firebomb.png"

function ENT:PlayerCantCastSpell(pl, spellid)
	pl:LM(62)
	return true
end

function ENT:Move(pl, move)
	if pl ~= self:GetOwner() then return end

	move:SetMaxSpeed(0)
	move:SetMaxClientSpeed(0)
end