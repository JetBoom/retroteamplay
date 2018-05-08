CLASS.Name = "Zombie"
CLASS.Group = "Melee"
CLASS.Description = "The sad foot soldier of the undead army.@Severely lacks in speed but makes up for it in power and health."
CLASS.Model = Model("models/Zombie/Poison.mdl")
CLASS.NeedsColorOverride = true
CLASS.Health = 200
CLASS.Speed = SPEED_SLOWEST
CLASS.SWEP = "weapon_zombie"

CLASS.Mana = 0
CLASS.ManaRegeneration = 0

CLASS.Image = "noxctf/classicons/zombie"
CLASS.RawIcon = "spellicons/summonzombie.png"

CLASS.NoStun = true
CLASS.CantPilot = true
CLASS.PoisonImmune = true

CLASS.EaseOfUse = 10
CLASS.Defense = 10
CLASS.Offense = 4
CLASS.GroupFighting = 6

function CLASS:CalcMainActivity(pl, velocity)
	if 0 < pl:GetVelocity():LengthSqr() then
		pl.CalcIdeal = ACT_WALK
	else
		pl.CalcIdeal = ACT_IDLE
	end

	return pl.CalcIdeal, pl.CalcSeqOverride
end
