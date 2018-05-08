CLASS.Name = "Templar"
CLASS.Group = "Magic"
CLASS.Description = "The ultimate support class. Uses strong clerical spells.@Could mean the difference between victory and defeat."
CLASS.Model = Model("models/vortigaunt.mdl")
CLASS.NeedsColorOverride = true
CLASS.Health = HEALTH_WEAKER
CLASS.Speed = SPEED_SLOW

CLASS.Mana = 125
CLASS.ManaRegeneration = 7

CLASS.Image = "noxctf/classicons/templar"
CLASS.RawIcon = "spellicons/sanctuary.png"

CLASS.DefaultSpellSheet = "Divine Bolt:Pixie Swarm:Hallowed Ground:Sanctuary:Astra:Protect From Elements:Counter Spell:Force Field:Star Burst:Inversion:Magic Arrow:Cure Poison:Levitate:Force Field:Regeneration:Channel Life"

CLASS.EaseOfUse = 4
CLASS.Defense = 10
CLASS.Offense = 5
CLASS.GroupFighting = 9

function CLASS:CalcMainActivity(pl, velocity)
	if pl:InVehicle() then
		pl.CalcSeqOverride = pl:LookupSequence("tvsitidle")
	else
		if not pl:OnGround() then
			pl.CalcIdeal = ACT_BARNACLE_PULL
		elseif pl:GetStatus("hallowedgroundchanneling") or pl.HealRing then
			pl.CalcSeqOverride = 38
		else
			local notmoving = velocity:Length() <= 0.5
			if pl:Crouching() then
				if notmoving then
					pl.CalcSeqOverride = 5
				else
					pl.CalcIdeal = ACT_WALK
				end
			elseif notmoving then
				pl.CalcIdeal = ACT_IDLE_ANGRY
			else
				pl.CalcIdeal = ACT_RUN
			end
		end
	end

	return pl.CalcIdeal, pl.CalcSeqOverride
end