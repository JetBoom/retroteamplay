CLASS.Name = "Assassin"
CLASS.Group = "Melee"
CLASS.Description = "Assassins are masters of infiltration and stealth.@They have the ability to backstab opponents and become invisible.@Their Voidwalk ability helps them escape quickly."
CLASS.Model = Model("models/player/group03/male_06.mdl")
CLASS.Health = HEALTH_WEAKER
CLASS.Speed = SPEED_FASTEST
CLASS.SWEP = "weapon_melee_dagger"

CLASS.Mana = 0
CLASS.ManaRegeneration = 0

--CLASS.Restrictions = {"ASLT", "ARNA"}
CLASS.Restrictions = { "ARNA"}

CLASS.Image = "noxctf/classicons/assassin"
CLASS.RawIcon = "spellicons/venomblade.png"

CLASS.DefaultSpellSheet = "Night Wish:-:Venom Blade:-:Evil Eye:-:Voidwalk:-:Nether Bomb:-:Shadowstorm:-:-:-:-:-"
CLASS.PoisonImmune = true

CLASS.EaseOfUse = 6
CLASS.Defense = 7
CLASS.Offense = 7
CLASS.GroupFighting = 3