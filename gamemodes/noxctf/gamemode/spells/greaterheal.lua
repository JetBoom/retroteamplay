SPELL.Name = "Greater Heal"
SPELL.Description = "Heal yourself or one ally with a continuous stream of health."
SPELL.Mana = 0
SPELL.Classes = {"Wizard", "Conjurer", "Dragoon", "Mage", "Templar"}
SPELL.Words = "ru un du"

SPELL.Icon = "spellicons/greaterheal.png"

SPELL.Inversable = true

function SPELL.Cast(pl)
	pl:StopIfOnGround()

	if pl:KeyDown(IN_USE) then
		local hit = NULL
		local tr = pl:TraceLine(200)
		local trent = tr.Entity
		if trent.SendLua and trent:Alive() and trent:Team() == pl:Team() and TrueVisible(pl:EyePos(), trent:NearestPoint(pl:EyePos())) then
			hit = trent
		else
			for i, ent in pairs(ents.FindInSphere(tr.HitPos, 256)) do
				if ent.SendLua and ent:Alive() and ent:Team() == pl:Team() and pl ~= ent and TrueVisible(pl:EyePos(), ent:NearestPoint(pl:EyePos())) then
					hit = ent
					break
				end
			end
		end
		if hit:IsValid() then
			timer.Create(pl:UniqueID().."GreaterHealing"..hit:UniqueID(), 0.2, 0, function() GreaterHealing(pl, hit, pl:Health(), pl:UniqueID(), hit:UniqueID()) end)
			pl:EmitSound("nox/heal.ogg", 90, 80)
			pl:CustomGesture(ACT_SIGNAL_FORWARD)
		end
	else
		timer.Create(pl:UniqueID().."GreaterHealing"..pl:UniqueID(), 0.2, 0, function() GreaterHealing(pl, pl, pl:Health(), pl:UniqueID(), pl:UniqueID()) end)
		pl:EmitSound("nox/heal.ogg", 90, 80)
		pl:CustomGesture(ACT_SIGNAL_HALT)
	end
end