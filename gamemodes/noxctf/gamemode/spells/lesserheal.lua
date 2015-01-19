SPELL.Name = "Lesser Heal"
SPELL.Description = "Heal yourself or one ally for 20 points of health."
SPELL.Mana = 35
SPELL.Classes = {"Wizard", "Conjurer"}
SPELL.Words = "du un in ru"

SPELL.Icon = "spellicons/lesserheal.png"

SPELL.Inversable = true

function SPELL.Cast(pl, override, owner)
	if pl:KeyDown(IN_USE) and not override then
		GenericHoming(pl, "LesserHeal", true)
		return
	end

	local ent = pl:GiveStatus("lesserheal")
	ent.Owner = owner or pl
end