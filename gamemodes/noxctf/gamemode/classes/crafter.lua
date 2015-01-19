CLASS.Name = "Crafter"
CLASS.Group = "Special"
CLASS.Description = "Can deploy and repair structures.@Press right mouse to access the building menu.@Use your physgun to move structures in to place.@Use your wrench to build or repair structures.@Being non-combat oriented they must rely heavily on teammates."
CLASS.Model = Model("models/player/monk.mdl")
CLASS.Health = HEALTH_NORMAL
CLASS.Speed = SPEED_NORMAL
CLASS.SWEPs = {"weapon_crafter_melee", "weapon_physgun"}
CLASS.PreferredSWEP = "weapon_crafter_melee"

CLASS.Mana = 50
CLASS.ManaRegeneration = 1.5

CLASS.Restrictions = {"TDM", "ARNA"}

CLASS.Image = "noxctf/classicons/crafter"
CLASS.RawIcon = "spellicons/crafter.png"

CLASS.EaseOfUse = 4
CLASS.Defense = 10
CLASS.Offense = 2
CLASS.GroupFighting = 2
