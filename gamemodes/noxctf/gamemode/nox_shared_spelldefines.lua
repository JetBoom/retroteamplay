Spells = {}
NameToSpell = {}
NameToSpellLower = {}
SpellFunctions = {}

function AddSpell(name, desc, mana, classes, words, funct, icon, inversable, hostile)
	local int = #Spells + 1

	local inserttab = {}
	for _, suggested in pairs(classes) do
		for i, classtab in ipairs(CLASSES) do
			if classtab.Name == suggested then
				inserttab[i] = true
			end
		end
	end

	local spell = {Name=name, Desc=desc, Mana=mana, CLASSES=inserttab, Inversable=inversable, Hostile=hostile}

	if words then
		local wordtab = {}
		for i, word in ipairs(string.Explode(" ", words)) do
			table.insert(wordtab, "nox/"..word.."2.ogg")
		end
		spell.Words = wordtab
		spell.Delay = #spell.Words * 0.1
	end

	if CLIENT and icon then
		spell.Icon = Material(icon, "smooth")
	end

	Spells[int] = spell
	NameToSpell[name] = int
	NameToSpellLower[string.lower(name)] = int
	SpellFunctions[int] = funct

	return spell
end

function AddAbility(name, desc, delay, classes, funct, icon, inversable, hostile)
	local spell = AddSpell(name, desc, nil, classes, nil, funct, icon, inversable, hostile)
	if spell then
		spell.Ability = true
		spell.Delay = delay
	end

	return spell
end

if CLIENT then spells = {} end

AddSpell("Fire Bomb", "Creates a giant flaming ball. The ball explodes shortly after its first bounce.", 80, {"Wizard"}, "zo ru un in zo ru", spells.FireBomb, "spellicons/starburst4.png", nil, true)
AddSpell("Missiles of Magic", "Create four homing balls of fire that explode on impact.", 20, {"Wizard"}, "et cha un cha un", spells.MissilesOfMagic, "spellicons/missilesofmagic.png", nil, true)
AddSpell("Lesser Heal", "Heal yourself or one ally for 20 points of damage.", 35, {"Wizard", "Conjurer"}, "du un in ru", spells.LesserHeal, "spellicons/lesserheal.png", true)
AddSpell("Greater Heal", "Heal yourself or one ally with a continuous stream of health.", 0, {"Conjurer", "Mage", "Templar"}, "ru un du", spells.GreaterHeal, "spellicons/greaterheal.png", true)
AddSpell("Haste", "Give yourself or an ally a speed boost for a short time.", 25, {"Wizard"}, "et cha cha", spells.Haste, "spellicons/haste.png", true, true)
AddSpell("Counter Spell", "Destroy all hostile spells around you.", 25, {"Wizard", "Conjurer", "Mage", "Templar", "Sorcerer", "Elementalist", "Necromancer"}, "zo du", spells.CounterSpell, "spellicons/counterspell.png", nil, true)
AddSpell("Pixie Swarm", "Send forth a swarm of pixies that will damage those who come near it.", 20, {"Conjurer", "Templar"}, "et zo cha zo", spells.PixieSwarm, "spellicons/pixieswarm.png", nil, true)
AddSpell("Force of Nature", "Call in to being a ghastly green ball of light that destroys all those foolish enough to cross it's path.", 75, {"Conjurer"}, "du ru zo", spells.ForceOfNature, "spellicons/forceofnature.png", nil, true)
AddSpell("Blink", "Teleport yourself instantly to a safe location.", 10, {"Wizard", "Conjurer", "Mage", "Templar", "Sorcerer", "Elementalist", "Necromancer"}, "cha et un", spells.Blink, "spellicons/blink.png")
AddSpell("Teleport to Target", "Teleport yourself instantly to where your cursor is.", 20, {"Wizard", "Mage", "Sorcerer"}, "zo un et cha", spells.TeleportToTarget, "spellicons/teleporttotarget.png")
AddSpell("Invisibility", "Make yourself invisible, so long as you stay still and niether take nor give damage.", 30, {"Wizard", "Mage"}, "et cha et cha", spells.Invisibility, "spellicons/invisibility.png", true)
AddSpell("Drain Mana", "Take the mana of all those around you while supplying yourself with your own magical energy.", 0, {"Wizard", "Sorcerer"}, "un ka zo in", spells.DrainMana, "spellicons/drainmana.png")
AddSpell("Anchor", "Stop yourself or others from teleporting for a short time.", 10, {"Wizard", "Mage", "Sorcerer", "Necromancer"}, "zo zo", spells.Anchor, "spellicons/anchor.png", true, true)
AddSpell("Scatterfrost", "Create a freezing ball of snow that splits in to many ice fragments.", 35, {"Mage"}, "ka et zo zo un", spells.Scatterfrost, "spellicons/scatterfrost.png", nil, true)
AddSpell("Meteor", "Bring flaming meteors crashing down wherever you desire.", 50, {"Conjurer"}, "ru ru", spells.Meteor, "spellicons/meteor.png", nil, true)
AddSpell("Lightning", "Lightning strikes whatever you happen to be looking at.", 30, {"Wizard", "Mage"}, "du in", spells.Lightning, "spellicons/lightning.png", nil, true)
AddSpell("Inversion", "Cause projectile-based spells near you to attack their caster.", 15, {"Wizard", "Conjurer", "Mage", "Templar", "Sorcerer", "Elementalist", "Necromancer"}, "ka in", spells.Inversion, "spellicons/inversion.png")
AddSpell("Pull", "Pull all nearby things towards you.", 20, {"Necromancer"}, "un un zo", spells.Pull, "spellicons/pull.png", nil, true)
AddSpell("Pulse", "Push or pull all nearby enemies.", 20, {"Wizard"}, "un zo un", spells.Push, "spellicons/push.png", nil, true)
AddAbility("Harpoon", "Shoot a harpoon to reel in foes that are too far to hit.", 10, {"Warrior"}, spells.Harpoon, "spellicons/harpoon.png", nil, true)
AddSpell("Force Field", "Reduce incoming damage by 25% until the field is destroyed.", 80, {"Wizard", "Mage", "Templar"}, "un et zo ka cha un et zo ka cha", spells.ForceField, "spellicons/forcefield.png", true, true)
AddAbility("War Cry", "Emit a thunderous roar that disturbs casters and stuns the meek.", 20, {"Warrior"}, spells.WarCry, "spellicons/warcry.png")
AddSpell("Channel Life", "Converts 30 health into 30 mana. Killing an enemy within 10 seconds will refund the health.", 0, {"Wizard", "Templar", "Sorcerer", "Necromancer", "Alchemist"}, "ka zo in", spells.ChannelLife, "spellicons/channellife.png")
AddAbility("Berserker Charge", "Charge head long in to battle, toppling anyone in your way.", 10, {"Warrior"}, spells.BerserkerCharge, "spellicons/berserkercharge.png", nil, true)
AddSpell("Slow", "Slow the movements of an enemy for a short time.", 15, {"Wizard", "Conjurer", "Mage", "Sorcerer", "Necromancer"}, "zo zo zo", spells.Slow, "spellicons/slow.png", nil, true)
AddSpell("Burn", "Create a small patch of flame where your cursor is.", 15, {"Wizard", "Conjurer", "Sorcerer", "Elementalist", "Necromancer"}, "zo zo un un", spells.Burn, "spellicons/burn.png", nil, true)
--AddSpell("Protect From Fire", "Reduce the damage taken from fire for a short time.", 30, {"Dragoon"}, "du ka ru un et", spells.ProtectFromFire, "spellicons/protectfromfire.png", true, true)
AddSpell("Protect From Shock", "Reduce the damage taken from shock for a short time.", 30, {}, "du ka ru un zo", spells.ProtectFromShock, "spellicons/protectfromshock.png", true, true)
AddSpell("Protect From Poison", "Reduce the damage taken from poison by 33% and prevents poisons from being applied for a short time.", 30, {"Necromancer", "Alchemist"}, "du ka ru un ka", spells.ProtectFromPoison, "spellicons/protectfrompoison.png", true, true)
AddSpell("Energy Bolt", "Channel a continuous stream of electricity so long as the caster remains still.", 0, {"Wizard", "Mage"}, "du ka ru et", spells.EnergyBolt, "spellicons/energybolt.png", nil, true)
AddSpell("Toxic Cloud", "Create a cloud of toxic gas at your cursor.", 40, {"Conjurer", "Necromancer", "Alchemist"}, "ka zo ru ka", spells.ToxicCloud, "spellicons/toxiccloud.png", nil, true)
AddSpell("Vampirism", "Convert half the damage given to others in to health.", 25, {"Conjurer", "Sorcerer"}, "ru du ka zo", spells.Vampirism, "spellicons/vampirism.png", true, true)
AddSpell("Fire Bolt", "Create a ball of flames to engulf your enemies.", 35, {"Wizard"}, "zo zo un", spells.FireBolt, "spellicons/fireball.png", nil, true)
AddSpell("Swap Location", "Swap the position of you and another person, so long as they're in view.", 15, {"Wizard", "Sorcerer", "Necromancer"}, "zo zo un zo", spells.SwapLocation, "spellicons/swap.png")
AddSpell("Protect From Cold", "Reduce the damage taken from cold for a short time.", 30, {}, "du ka ru ka et cha", spells.ProtectFromCold, "spellicons/protectfromenchants.png", true, true)
AddSpell("Shock", "Emit a static discharge, damaging anyone nearby.", 35, {"Wizard", "Mage"}, "du in cha et", spells.Shock, "spellicons/shock.png", true, true)
AddAbility("Dragoon Flight", "Allows temporary flight.", 20, {"Dragoon"}, spells.DragoonFlight, "spellicons/dragoonflight.png", nil, true)
AddAbility("Inferno Blast", "Summons a massive ball of fire.", 15, {"Dragoon"}, spells.DragoonFireBall, "spellicons/infernoblast.png", nil, true)
AddSpell("Sun Beam", "Create a concentrated beam of sun light at your target.", 50, {"Wizard", "Conjurer"}, "zo ru zo ru et ru", spells.SunBeam, "spellicons/sunbeam.png", nil, true)
AddAbility("Night Wish", "Conceal yourself and stay hidden so long as you remain motionless or crouched.", 10, {"Assassin"}, spells.NightWish, "spellicons/nightwish.png")
AddAbility("Venom Blade", "Adds a deadly poison to the user's next attack.", 10, {"Assassin"}, spells.VenomBlade, "spellicons/venomblade.png")
AddSpell("Fire Arrow", "Enchant your next arrow with fire.", 25, {"Archer"}, "zo in zo zo ru", spells.FireArrow, "spellicons/firebullet.png")
AddSpell("Lightning Arrow", "Enchant your next arrow with lightning.", 40, {"Archer"}, "zo in et du", spells.LightningArrow, "spellicons/lightningbullet.png")
AddSpell("Vampiric Arrow", "Enchant your next arrow to leech health.", 30, {"Archer"}, "zo in du un", spells.VampiricArrow, "spellicons/vampiricbullet.png")
AddSpell("Bouncer Arrow", "Enchant your next arrow to bounce off of surfaces.", 30, {"Archer"}, "zo in zo zo et", spells.BouncerArrow, "spellicons/bouncerbullet.png")
AddSpell("Silver Arrow", "Enchant your next arrow to counter all magic. Hitting an enemy removes all of thier status effects.", 30, {"Archer"}, "zo in cha ka in", spells.SilverArrow, "spellicons/silverbullet.png")
AddSpell("Sprite Arrow", "Enchant your next arrow to home in on enemies.", 30, {"Archer"}, "zo in et in zo", spells.SpriteArrow, "spellicons/magicbullet.png")
--AddSpell("Detonator Arrow", "Enchant your next arrow to detonate when enemies come nearby.", 50, {"Archer"}, "zo et zo zo ru ru", spells.DetonatorArrow, "spellicons/russianroulette.png")
AddSpell("Poison", "Invoke a magic poison to plague enemies.", 15, {"Conjurer", "Necromancer", "Alchemist"}, "in ka", spells.Poison, "spellicons/poison.png", nil, true)
AddSpell("Cure Poison", "Magically flush all toxins from yourself or an ally.", 10, {"Conjurer", "Templar"}, "et du ka", spells.CurePoison, "spellicons/curepoison.png", true)
--AddAbility("Evade", "Leap far in the air to avoid danger.", 7, {"Assassin"}, spells.Evade, "spellicons/evade.png")
AddAbility("Eye of the Wolf", "Your eyes become like that of a wolf as hidden things are brought to light.", 20, {"Warrior"}, spells.EyeOfTheWolf, "spellicons/eyeofthewolf.png")
AddSpell("Infravision", "Briefly reveal all things around you that are invisible.", 20, {"Conjurer", "Necromancer"}, "zo cha ka et", spells.Infravision, "spellicons/infravision.png", true)
AddSpell("Static Ball", "Creates an orb of electricity that zaps nearby enemies before exploding.", 40, {"Mage"}, "cha ka et du ka et zo", spells.StaticBall, "spellicons/staticball.png", nil, true)
AddSpell("Protrusion", "Call upon massive ice shards that travel across the ground in front of you.", 45, {"Mage"}, "ka et cha zo ru ka", spells.Protrusion, "spellicons/protrusion.png", nil, true)
AddSpell("Air Hike", "Condense the air below you to create a platform you can jump on.", 15, {"Mage"}, "zo ka cha zo", spells.AirHike, "spellicons/run.png")
AddSpell("Ice Spear", "Freeze the air into a spear of ice to pierce through your enemies.", 30, {"Mage"}, "ka et un", spells.IceSpear, "spellicons/icespear.png", nil, true)
AddSpell("Stun", "Completely stop the movement of an enemy for a short time.", 20, {}, "zo zo zo zo", spells.Stun, "spellicons/stun.png", nil, true)
AddSpell("Sanctuary", "Bless a point of land with holy markings that prevent enemies from passing while healing friendlies.", 50, {"Templar"}, "zo ru in zo cha cha", spells.Sanctuary, "spellicons/sanctuary.png")
AddSpell("Divine Bolt", "Call down the fury of Heaven on a point.", 35, {"Templar"}, "et du in un", spells.DivineBolt, "spellicons/divinebolt.png", nil, true)
AddSpell("Star Burst", "Control a burning light that splits in to an inferno of small explosions.", 45, {"Templar"}, "zo zo in cha ru ru zo", spells.StarBurst, "spellicons/starburst3.png", nil, true)
AddSpell("Heal Ring", "Use an immense amount of your mana to completely heal everyone near you!", 70, {"Templar"}, "du ru cha et un zo ka un zo et in ru", spells.HealRing, "spellicons/healring.png", nil, true)
AddSpell("Levitate", "Become light as a feather to hover above the ground.", 25, {"Templar"}, "ka ru zo", spells.Levitate, "spellicons/levitate.png")
AddSpell("Regeneration", "Gradually heal yourself or an ally over time.", 30, {"Templar"}, "du ru cha zo un", spells.Regeneration, "spellicons/regeneration.png", true)
AddSpell("Magic Arrow", "Create a small, fast moving shot of fire.", 20, {"Templar"}, "in zo ru", spells.MagicArrow, "spellicons/moonglow.png", nil, true)
AddSpell("Tag", "Mark an enemy with a tag that reveals their position.", 20, {"Wizard", "Conjurer", "Necromancer"}, "ka et zo", spells.Tag, "spellicons/tag.png", nil, true)
--AddSpell("Explosion", "A delayed explosion on a whatever this hits.", 35, {"Mage", "Wizard", "Sorcerer"}, "zo ru cha ka ru du", spells.Explosion, "spellicons/flamestrike.png", nil, true)
AddSpell("Electron Ball", "A ball of pure energy that discharges on impact.", 35, {"Wizard", "Mage", "Sorcerer"}, "du et ka et zo et", spells.ElectronBall, "spellicons/obliteration.png", nil, true)
AddSpell("Typhoon", "Summon a huge whirlwind that sucks in both enemies and projectiles alike.", 75, {"Sorcerer"}, "ka cha et in ru zo ru et du zo cha cha zo in", spells.Typhoon, "spellicons/typhoon.png", nil, true)
AddSpell("Flame Strike", "Engulf an area in a magical flame.", 35, {"Sorcerer"}, "ru ru in zo ru", spells.FlameStrike, "spellicons/explosion.png", nil, true)
AddSpell("Fire Sprites", "Summon two fire sprites that do their best to home in on far away targets.", 40, {"Sorcerer"}, "in ru ru zo cha", spells.FireSprites, "spellicons/firesprites.png", nil, true)
AddSpell("Hex", "Curse an enemy to take 50% enhanced damage for a short time.", 40, {"Sorcerer", "Necromancer"}, "du cha du in", spells.Hex, "spellicons/dispelundead.png", nil, true)
AddSpell("Jolt", "A massive lightning storm that damages anything that happens to be under it.", 40, {}, "et du ka in zo", spells.Jolt, "spellicons/jolt.png", nil, true)
AddSpell("Sparkler", "Launches a concentrated bolt of electricity.", 35, {"Wizard", "Mage"}, "du et ka", spells.Sparkler, "spellicons/sparkler.png", nil, true)
AddSpell("Grapple Arrow", "Enchant your next arrow with a magical rope.", 40, {"Archer"}, "et zo et zo zo un", spells.GrappleArrow, "spellicons/grapplearrow.png")
AddSpell("Blood Boil", "A curse that turns people into living bombs.", 30, {"Sorcerer", "Necromancer"}, "et du in du ka", spells.BloodBoil, "spellicons/bloodpact.png", nil, true)
AddSpell("Poison Rain", "Call down a torrent of poison that does persistent damage to anyone who gets under it.", 65, {"Sorcerer"}, "et du ka in zo cha zo ru ru zo", spells.PoisonRain, "spellicons/acidrain.png", nil, true)
AddSpell("Flame Spiral", "Summon a powerful ball that accelerates over time.", 40, {"Sorcerer"}, "zo zo ru un", spells.FlameSpiral, "spellicons/flamespiral.png")
AddSpell("ManaStun", "Completely stop the spellcasting of an enemy for a short time.", 20, {}, "ru ru ru ru", spells.ManaStun, "spellicons/manastun.png")
AddSpell("Zolt", "Precipitate a raging storm cloud that strikes down those under it with a lightning bolt.", 75, {"Mage"}, "cha cha du ka ka et cha et zo cha", spells.Zolt, "spellicons/zolt.png", nil, true)
AddSpell("Flare", "Summon a ball of flame that seeks out nearby enemies.", 45, {"Wizard", "Sorcerer"}, "zo ru zo ru ru zo", spells.Flare, "spellicons/flare.png", nil, true)
AddSpell("Black Hole Sun", "Create a miniature black hole that destroys anything caught inside it.", 100, {"Conjurer"}, "et zo ka ka ka zo", spells.BlackHoleSun, "spellicons/blackholesun.png", nil, true)
AddSpell("Volcanic Blast", "Launch a giant, destructive ball of fire.", 100, {"Elementalist"}, "zo zo ka ru ru un zo zo un", spells.VolcanicBlast, "spellicons/volcanicblast.png", nil, true)
AddSpell("Armageddon", "The elementalist's ultimate spell. Sends three waves of firebolts to every enemy nearby.", 175, {"Elementalist"}, "ka ru zo et ka ka un un", spells.Armageddon, "spellicons/meteorshards.png", nil, true)
--AddSpell("Meltdown", "Saturate the surrounding area with many small explosions.", 100, {"Elementalist"}, "zo du ru ru ka", spells.Meltdown, "spellicons/firebomb.png", nil, true)
AddSpell("Gust", "Send a blast of wind in the direction you're facing.", 50, {"Elementalist"}, "in in un", spells.Gust, "spellicons/gust.png", nil, true)
AddSpell("Earthquake", "Shatter the ground around you, dealing damage over time to anything touching the ground.", 75, {"Elementalist"}, "zo in ru in ka in zo ru ka", spells.Earthquake, "spellicons/earthquake.png", nil, true)
AddSpell("Geyser", "Create a geyser that deals damage and launches objects skyward.", 40, {"Elementalist"}, "un ka et in", spells.Geyser, "spellicons/geyser.png", nil, true)
AddSpell("Hydro Pump", "Pump massive amounts of water in the direction you're facing.", 20, {"Elementalist"}, "et et et un ka zo", spells.HydroPump, "spellicons/hydropump.png", nil, true)
AddSpell("Whirlwind", "Ride a small tornado forwards, damaging and knocking back any struck enemies.", 35, {"Elementalist"}, "in zo ru in", spells.Whirlwind, "spellicons/whirlwind.png", nil, true)
AddSpell("Aegis", "Earthen barrier that reduces the damage taken from non-elemental attacks by 40%.", 50, {"Elementalist"}, "ka in ru ka", spells.Aegis, "spellicons/aegis.png", nil, true)
AddSpell("Cauterize", "Cleanse yourself with fire, recovering health while receiving burn damage.", 40, {"Elementalist"}, "in cha cha ru et zo", spells.Cauterize, "spellicons/flickerflame.png", nil, true)
AddSpell("Flamethrower", "Scorch enemies in front of you with a fiery breath.", 20, {"Dragoon"}, "in ru un ru un", spells.Flamethrower, "spellicons/flamethrower.png", nil, true)
AddSpell("Salamander Skin", "Absorbs minor fire damage and halves major fire damage.", 30, {"Dragoon"}, "zo ka un un ka", spells.SalamanderSkin, "spellicons/salamanderscales.png", nil, true)
AddSpell("Scorch", "Creative a volatile ball of elemental fire that seeks out nearby enemies.", 75, {"Elementalist"}, "zo ru ru ru zo ka in in cha du", spells.Scorch, "spellicons/scorch.png", nil, true)
AddSpell("Protect From Elements", "Reduce the damage taken from fire, shock and ice by 33% for a short time.", 50, {"Wizard", "Conjurer", "Mage", "Templar", "Elementalist"}, "du ka ru un et", spells.ProtectFromElements, "spellicons/protectfromshock.png", true, true)
AddSpell("Comet", "Call upon a giant ball of ice to crush your enemies.", 50, {"Mage"}, "ru ka ru", spells.Comet, "spellicons/meteor.png", nil, true)
AddSpell("Napalm Bomb", "Shoot a ball of fire that leaves the ground in flames wherever it explodes.", 75, {"Sorcerer", "Elementalist"}, "zo ru un in zo zo ru un", spells.NapalmBomb, "spellicons/firebomb.png", nil, true)
AddAbility("Sanctify", "A powerful incantation that dissipates debuffs and reduces incoming damage by 20%.", 25, {"Paladin"}, spells.Sanctify, "spellicons/sanctify.png")
AddAbility("Oversoul", "A divine aegis that briefly wards off all damage.", 30, {"Paladin"}, spells.Oversoul, "spellicons/oversoul.png")
AddAbility("Repel", "Construct a wall of light that inhibits enemy movement and reflects hostile spells.", 18, {"Paladin"}, spells.Repel, "spellicons/repel.png", nil, true)
AddAbility("Sacred Vow", "Vow to safeguard an ally, taking half of their damage and moving faster as long as you're together.", 2, {"Paladin"}, spells.SacredVow, "spellicons/sacredvow.png")
AddAbility("Holy Nova", "Create a delayed explosion of holy light that damages and blinds enemies while healing allies.", 20, {"Paladin"}, spells.HolyNova, "spellicons/holynova.png", nil, true)
AddAbility("Smite", "The paladin uses his raw strength to create a shockwave that slows and damages enemies.", 7, {"Paladin"}, spells.Smite, "spellicons/smite.png", nil, true)
AddSpell("Astra", "Nullify the next hostile status you or an ally would take, or remove one immediately.", 30, {"Alchemist", "Templar"}, "zo et zo et", spells.Astra, "spellicons/astra.png", true)
AddAbility("Evil Eye", "The assassin's keen senses allow it to sense nearby life.", 20, {"Assassin"}, spells.EvilEye, "spellicons/evileye.png")
--AddAbility("Tread Lightly", "Makes you imperceptible to nearby foes while invisible as you tread by slowly.", 5, {"Assassin"}, spells.ThreadLightly, "spellicons/assassinthreadlightly.png")
AddAbility("Brute", "Pumps adrenaline all over your body, attacking twice as fast but taking double damage.", 15, {"Warrior"}, spells.Brute, "spellicons/brutewarrior.png")
AddSpell("Rasp", "Conjure forth ethereal flames with potent mana dissipating properties.", 15, {"Alchemist", "Sorcerer"}, "ru zo et", spells.Rasp, "spellicons/rasp.png", nil, true)
AddSpell("Arcane Explosion", "Creates an explosion around the caster.", 30, {"Necromancer"}, "ru ru ka zo ka", spells.ArcaneExplosion, "spellicons/flamestrike.png", nil, true)
AddSpell("Soul Explosion", "Destroys a nearby soul to cause a violent explosion.", 15, {"Necromancer"}, "in ru zo", spells.SoulExplosion, "spellicons/fear.png", nil, true)
AddSpell("Blood Well", "Turns a nearby soul into a Blood Well which quickly heals allies. Also gives 60% physical protection.", 50, {"Necromancer"}, "zo ru in et et ru", spells.BloodWell, "spellicons/bloodwell.png", nil, true)
AddSpell("Power Well", "Turns a nearby soul into a Power Well which quickly damages enemies.", 70, {"Necromancer"}, "ka cha zo zo in", spells.PowerWell, "spellicons/powerwell.png", nil, true)
AddSpell("Cursed Skulls", "Summons animated skulls that will seek out and steal mana from nearby enemies.", 45, {"Necromancer"}, "du du et zo du zo", spells.CursedSkulls, "spellicons/cursedskulls.png", nil, true)
AddSpell("Mana Sickness", "Cursed enemies will gain 66% less mana from obelisks.", 30, {"Necromancer"}, "un ka cha zo zo in", spells.ManaSickness, "spellicons/manasickness.png")
--AddSpell("Flesh Wound", "Turns a soul into flesh armor that reduces non-elemental damage taken by 60%.", 50, {"Necromancer"}, "ru du et cha zo ru ru in", spells.FleshWound, "spellicons/summonzombie.png")
AddSpell("Storm Blade", "Imbues your sword with lightning. Attacks will bounce electricity between nearby enemies", 0, {"Spell Saber"}, "du ka ru zo zo", spells.StormBlade, "spellicons/stormblade.png")
AddSpell("Flame Blade", "Imbues your sword with flames. Attacks will burn enemies for a few seconds.", 0, {"Spell Saber"}, "zo zo un zo zo", spells.FlameBlade, "spellicons/flameblade.png")
AddSpell("Null Blade", "Imbues your sword with negative magic. Attacks will burn mana. Counter Spells if the ground is hit.", 0, {"Spell Saber"}, "un ka zo zo zo", spells.NullBlade, "spellicons/nullblade.png")
AddSpell("Corrupted Blade", "Imbues your sword with a curse. Attacks will disorient your enemies.", 0, {"Spell Saber"}, "et et cha zo zo", spells.CorruptedBlade, "spellicons/corruptedblade.png")
AddSpell("Shockwave Blade", "Imbues your sword with gravity. Attacks will knock enemies back. Launches you if the ground is hit.", 0, {"Spell Saber"}, "un un un zo zo", spells.ShockwaveBlade, "spellicons/shockwaveblade.png")
AddSpell("Frost Blade", "Imbues your sword with ice. Attacks will create an ice path that freezes enemies.", 0, {"Spell Saber"}, "ka et cha zo zo", spells.FrostBlade, "spellicons/frostblade.png")
AddSpell("Blade Spirits", "Summons three Blade Spirits that manifest themselves when you attack.", 20, {"Spell Saber"}, "et zo du cha", spells.BladeSpirit, "spellicons/bladespirit.png", nil, true)
AddAbility("Sword Throw", "Throws your weapon where you're facing. Activate again to launch yourself towards it.", 0, {"Spell Saber"}, spells.SwordThrow, "spellicons/swordthrow.png", nil, true)
AddSpell("Sanguine Blade", "Imbues your sword with vampiric energies. Attacks will heal you slowly for the damage dealt.", 0, {"Spell Saber"}, "ru du ka zo zo", spells.SanguineBlade, "spellicons/sanguineblade.png")
AddSpell("Fist of Vengeance", "Summon a colossal megalithic hand to fall from above and smite your enemies.", 60, {"Conjurer"}, "ka in un zo", spells.FistOfVengeance, "spellicons/fistofvengeance.png", nil, true)
AddSpell("Arrow Volley", "Enchant your next arrow to split into a volley of arrows.", 50, {"Archer"}, "du et zo zo et du", spells.ArrowVolley, "spellicons/russianroulette.png")
AddSpell("Ruin", "Corrode the material of your enemy's weapon, reducing its effectiveness.", 20, {"Alchemist", "Necromancer"}, "cha zo cha", spells.Ruin, "spellicons/ruin.png", nil, true)
AddSpell("Petrify", "Turn an enemy to stone, slowing them in the process.", 0, {"Alchemist", "Necromancer", "Sorcerer"}, "du et ru ka zo cha", spells.Petrify, "spellicons/aurify.png", nil, true)
AddSpell("Protometeor", "Call a gigantic infernal body from the sky to wreak catastrophic amounts of damage.", 90, {"Alchemist", "Elementalist"}, "zo cha ka ru ru ru in du zo ru", spells.Protometeor, "spellicons/protometeor.png", nil, true)
AddSpell("Death", "Cull nearby weak enemies, instantly killing them and absorbing their lifeforce.", 30, {"Alchemist"}, "zo du zo du zo du zo", spells.Death, "spellicons/death.png", nil, true)
AddAbility("Voidwalk", "Slip into the void, becoming ethereal as you move to your destination.", 7, {"Assassin"}, spells.Voidwalk, "spellicons/voidwalk.png")
AddAbility("Leap", "Jump high into the air to peform an aerial strike.", 10, {"Warrior"}, spells.Leap, "spellicons/leap2.png", nil, true)
AddAbility("Shadowstorm", "Invoke shadows from the void to augment your stealth.", 30, {"Assassin"}, spells.Shadowstorm, "spellicons/shadowstorm.png")
AddAbility("Nether Bomb", "A sapper charge of dark energy that strengthens over time. Damages and mana stuns.", 5, {"Assassin"}, spells.NetherBomb, "spellicons/evade.png")
AddAbility("Dragoon Dash", "Run with furious speed while leaving a blazing trail in your wake.", 15, {"Dragoon"}, spells.DragoonDash, "spellicons/dragoondash.png", nil, true)
AddSpell("Dragon's Blood", "Heals over time while channeling and the same amount over time when it ends.", 0, {"Dragoon"}, "ru in du", spells.DragonBlood, "spellicons/dragonblood.png", true)
AddSpell("Fiery Talon", "Send out a wave of flaming projectiles.", 30, {"Dragoon"}, "zo zo ka un", spells.FieryTalon, "spellicons/fierytalon.png", nil, true)
AddSpell("Hallowed Ground", "Channels an area that will heal and damage when it ends based on damage taken inside.", 40, {"Templar"}, "du ru cha et un", spells.HallowedGround, "spellicons/light.png", nil, true)
AddSpell("Discharge", "Sends an arcing bolt of lightning.", 35, {}, "", spells.Discharge, "spellicons/jolt.png", nil, true)
