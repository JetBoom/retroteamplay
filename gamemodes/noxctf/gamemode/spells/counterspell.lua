SPELL.Name = "Counter Spell"
SPELL.Description = "Destroy all hostile spells around you."
SPELL.Mana = 25
SPELL.Classes = {"Wizard", "Conjurer", "Mage", "Templar", "Sorcerer", "Elementalist"}
SPELL.Words = "zo du"

SPELL.Icon = "spellicons/counterspell.png"

SPELL.Inversable = nil
SPELL.Hostile = true

function SPELL.Cast(pl)
	CounterSpellEffect(pl, pl:EyePos())

	pl:CustomGesture(ACT_SIGNAL_HALT)
end