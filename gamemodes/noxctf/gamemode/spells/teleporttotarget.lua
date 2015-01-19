SPELL.Name = "Teleport to Target"
SPELL.Description = "Teleport yourself instantly to where your cursor is."
SPELL.Mana = 20
SPELL.Classes = {"Wizard", "Mage", "Sorcerer"}
SPELL.Words = "zo un et cha"

SPELL.Icon = "spellicons/teleporttotarget.png"

function SPELL.Cast(pl)
	if pl:IsCarrying() then
		pl:LM(30)
		return true
	end

	if not pl:CanTeleport() then pl:LMR(55) return true end

	local _start = pl:GetShootPos()
	local tr = util.TraceLine({start = _start, endpos = _start + pl:GetAimVector() * 275, filter=pl, mask=MASK_PLAYERSOLID})
	return DoTeleportToTarget(pl, tr)
end