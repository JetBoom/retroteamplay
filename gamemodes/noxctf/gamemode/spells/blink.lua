SPELL.Name = "Blink"
SPELL.Description = "Teleport yourself instantly to a safe location."
SPELL.Mana = 10
SPELL.Classes = {"Wizard", "Conjurer", "Mage", "Templar", "Sorcerer", "Elementalist"}
SPELL.Words = "cha et un"

SPELL.Icon = "spellicons/blink.png"

function SPELL.Cast(pl)
	if pl:IsCarrying() then pl:LM(30) return true end
	if not pl:CanTeleport() then pl:LMR(55) return true end

	pl:GiveStatus("blink", 2)
	pl:Stun(2)
	pl:ManaStun(2)
end