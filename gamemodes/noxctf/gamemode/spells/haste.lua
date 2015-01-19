SPELL.Name = "Haste"
SPELL.Description = "Give yourself or an ally a speed boost for a short time."
SPELL.Mana = 10
SPELL.Classes = {"Wizard"}
SPELL.Words = "et cha cha"

SPELL.Icon = "spellicons/haste.png"

SPELL.Inversable = true
SPELL.Hostile = true

function SPELL.Cast(pl, override)
	if pl:KeyDown(IN_USE) and not override then
		GenericHoming(pl, "Haste", true)
		return
	end

	pl:GiveStatus("haste", 25)
end