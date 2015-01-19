local allmaterials = {RESISTANCE_CONCRETE, RESISTANCE_RUBBER, RESISTANCE_METAL, RESISTANCE_WOOD}
local allmaterials2 = {RESISTANCE_CONCRETE, RESISTANCE_METAL, RESISTANCE_WOOD}
local allmaterials3 = {RESISTANCE_METAL, RESISTANCE_WOOD}

local nometalmaterial = {[RESISTANCE_METAL] = ""}
local norubbermaterial = {[RESISTANCE_RUBBER] = ""}
local nowoodmaterial = {[RESISTANCE_WOOD] = ""}
local noconcretematerial = {[RESISTANCE_CONCRETE] = ""}

function GM:AddProp(name, model, group, health, type, defres, matover, usemats, floor, nowater, max, teammax, count, freq, callback)
	table.insert(PROPTYPES, {
	Name = name,
	Model = Model(model),
	Group = group,
	PHealth = health,
	Type = type,
	DefaultResistance = (defres or nil),
	MaterialOverrides = (matover or nil),
	UsableMaterials = (usemats or nil),
	SolidBase = (floor or false),
	NoWater = (nowater or false),
	Max = (max or nil),
	TeamMax = (teammax or nil),
	CountsTowards = (count or nil),
	ClusterPrevention = (freq or nil),
	Callback = (callback or nil)})
end

GM:AddProp("Slim Wall", "models/props_lab/blastdoor001b.mdl", "Props", 600, "prop_prop", RESISTANCE_METAL, nometalmaterial, allmaterials)
GM:AddProp("Wide Wall", "models/props_lab/blastdoor001c.mdl", "Props", 750, "prop_prop", RESISTANCE_METAL, nometalmaterial, allmaterials)
GM:AddProp("4x4 Box", "models/props_junk/wood_crate001a.mdl", "Props", 250, "prop_prop", RESISTANCE_WOOD, nowoodmaterial, allmaterials)
GM:AddProp("4x8 Box", "models/props_junk/wood_crate002a.mdl", "Props", 550, "prop_prop", RESISTANCE_WOOD, nowoodmaterial, allmaterials)
GM:AddProp("Stick", "models/props_docks/dock01_pole01a_128.mdl", "Props", 500, "prop_prop", RESISTANCE_WOOD, nowoodmaterial, allmaterials2)
GM:AddProp("Wood Pallet", "models/props_junk/wood_pallet001a.mdl", "Props", 500, "prop_prop", RESISTANCE_WOOD, nowoodmaterial)
GM:AddProp("Fence", "models/props_wasteland/wood_fence01a.mdl", "Props", 600, "prop_prop", RESISTANCE_WOOD, nowoodmaterial, allmaterials)
GM:AddProp("Cylinder", "models/props_c17/oildrum001.mdl", "Props", 450, "prop_prop", RESISTANCE_METAL, nometalmaterial, allmaterials)
GM:AddProp("Short Panel", "models/props_debris/metal_panel02a.mdl", "Props", 400, "prop_prop", RESISTANCE_METAL, nometalmaterial, allmaterials3)
GM:AddProp("Long Panel", "models/props_debris/metal_panel01a.mdl", "Props", 500, "prop_prop", RESISTANCE_METAL, nometalmaterial, allmaterials3)
GM:AddProp("Shield Barricade", "models/props_combine/combine_barricade_short01a.mdl", "Props", 500, "prop_prop", RESISTANCE_METAL, nometalmaterial)
GM:AddProp("Bars", "models/props_wasteland/prison_gate001b.mdl", "Props", 800, "prop_prop", RESISTANCE_METAL, nometalmaterial, allmaterials3)
GM:AddProp("Barrier", "models/props_c17/concrete_barrier001a.mdl", "Props", 650, "prop_prop", RESISTANCE_CONCRETE, noconcretematerial, allmaterials)
GM:AddProp("Wide Fortress Wall", "models/props_combine/combine_barricade_med03b.mdl", "Props", 850, "prop_prop", nil, nometalmaterial, allmaterials2)
GM:AddProp("Short Fortress Wall", "models/props_combine/combine_barricade_med01a.mdl", "Props", 800, "prop_prop", nil, nometalmaterial, allmaterials2)
GM:AddProp("Tall Fortress Wall", "models/props_combine/combine_barricade_tall01a.mdl", "Props", 800, "prop_prop", nil, nometalmaterial, allmaterials2)
GM:AddProp("Slotted Fortress Wall", "models/props_combine/combine_barricade_med02b.mdl", "Props", 800, "prop_prop", nil, nometalmaterial, allmaterials2)

--Too many proptypes
table.insert(PROPTYPES, {
	Name="Shield Window",
	Group="Props",
	Model=Model("models/props_combine/combine_window001.mdl"),
	Type="prop_prop",
	PHealth=650,
	MaterialOverrides = nometalmaterial,
	DefaultResistance = RESISTANCE_METAL
})

table.insert(PROPTYPES, {
	Name="Tube",
	Group="Props",
	Model=Model("models/props_phx/construct/windows/window_curve360x2.mdl"),
	Type="prop_prop",
	PHealth=700,
	DefaultResistance = RESISTANCE_CONCRETE,
	MaterialOverrides = noconcretematerial,
	UsableMaterials = allmaterials2
})

table.insert(PROPTYPES, {
	Name="Tube - Curved",
	Group="Props",
	Model=Model("models/hunter/tubes/tubebend2x2x90square.mdl"),
	Type="prop_prop",
	PHealth=700,
	DefaultResistance = RESISTANCE_CONCRETE,
	MaterialOverrides = noconcretematerial,
	UsableMaterials = allmaterials2
})

table.insert(PROPTYPES, {
	Name="Tube - 3 Way",
	Group="Props",
	Model=Model("models/hunter/tubes/tube2x2xt.mdl"),
	Type="prop_prop",
	PHealth=700,
	DefaultResistance = RESISTANCE_CONCRETE,
	MaterialOverrides = noconcretematerial,
	UsableMaterials = allmaterials2
})

table.insert(PROPTYPES, {
	Name="Platform",
	Group="Props",
	Model=Model("models/Mechanics/articulating/stand.mdl"),
	Type="prop_prop",
	PHealth=750,
	DefaultResistance = RESISTANCE_CONCRETE
})

table.insert(PROPTYPES, {
	Name="Ramp",
	Group="Props",
	Model=Model("models/hunter/triangles/2x2x1.mdl"),
	Type="prop_prop",
	PHealth=750,
	MaterialOverrides = nometalmaterial,
	UsableMaterials = allmaterials2
})

table.insert(PROPTYPES, {
	Name="Small Mana Extractor",
	Group="Resource Management",
	Model=Model("models/props_combine/combine_light001a.mdl"),
	Type="prop_smallmanaextractor",
	Max=16,
	TeamMax=32,
	PHealth=700,
	Callback=function(pl, ent) pl:PrintMessage(HUD_PRINTTALK, "This will convert an obelisk's Mana in to a storable form. It needs to be placed appropriately near a Mana Obelisk.") local ang = ent:GetAngles() ang.yaw = math.NormalizeAngle(ang.yaw + 180) ent:SetAngles(ang) end,
	MaterialOverrides = nometalmaterial,
	DefaultResistance = RESISTANCE_ELECTRONIC
})

table.insert(PROPTYPES, {
	Name="Mana Capacitor",
	Group="Resource Management",
	Model=Model("models/props_trainstation/trainstation_ornament001.mdl"),
	Type="prop_manacapacitor",
	PHealth=1000,
	Max=8,
	TeamMax=24,
	Callback=function(pl, ent) pl:PrintMessage(HUD_PRINTTALK, "This will store mana gained from Mana Extracters and nearby structures can then use the stored mana.") end,
	MaterialOverrides = nometalmaterial,
	DefaultResistance = RESISTANCE_ELECTRONIC
})

table.insert(PROPTYPES, {
	Name="Mana Translocator",
	Group="Resource Management",
	Model=Model("models/props_c17/utilityconnecter006c.mdl"),
	Type="prop_manatranslocator",
	PHealth=700,
	Max=8,
	TeamMax=32,
	Callback=function(pl, ent) pl:PrintMessage(HUD_PRINTTALK, "Attaching this to an active Mana Capacitor will allow you to link together another capacitor that it's pointing to.") end,
	MaterialOverrides = nometalmaterial,
	DefaultResistance = RESISTANCE_ELECTRONIC
})

table.insert(PROPTYPES, {
	Name="Mana Relay",
	Group="Resource Management",
	Model=Model("models/props_c17/utilityconducter001.mdl"),
	Type="prop_manarelay",
	PHealth=350,
	Max=8,
	TeamMax=24,
	Callback=function(pl, ent) pl:PrintMessage(HUD_PRINTTALK, "This is a much smaller capacitor that does not power nearby structures but can be used as a relay station for translocators.") end,
	MaterialOverrides = nometalmaterial,
	DefaultResistance = RESISTANCE_ELECTRONIC
})

table.insert(PROPTYPES, {
	Name="Spawn Point",
	Group="Deployables",
	Model=Model("models/props_combine/combine_mine01.mdl"),
	Type="prop_spawnpoint",
	Max=4,
	TeamMax=20,
	PHealth=1000,
	Callback=function(pl, ent) pl:PrintMessage(HUD_PRINTTALK, "Press USE on it to set your spawn.") end,
	MaterialOverrides = nometalmaterial,
	DefaultResistance = RESISTANCE_ELECTRONIC
})

table.insert(PROPTYPES, {
	Name="Mana Dispenser",
	Group="Powered Deployables",
	Model=Model("models/props_trainstation/trainstation_ornament002.mdl"),
	Type="prop_obelisk",
	PHealth=250,
	Max=4,
	TeamMax=16,
	MaterialOverrides = nometalmaterial,
	DefaultResistance = RESISTANCE_ELECTRONIC
})

table.insert(PROPTYPES, {
	Name="Teleport Pad",
	Group="Deployables",
	Model=Model("models/props_lab/teleplatform.mdl"),
	Type="prop_teleportpad",
	Max=6,
	TeamMax=20,
	PHealth=400,
	Callback=function(pl, ent) pl:PrintMessage(HUD_PRINTTALK, "Press USE on this telepad and then press USE on another telepad to link them.") end,
	MaterialOverrides = nometalmaterial,
	DefaultResistance = RESISTANCE_ELECTRONIC,
	NoRemove = true,
	NoWater = true
})

table.insert(PROPTYPES, {
	Name="Vehicle Pad",
	Group="Powered Deployables",
	Model=Model("models/hunter/plates/plate8x8.mdl"),
	Type="prop_vehiclepad",
	PHealth=2000,
	Max=2,
	TeamMax=5,
	MaterialOverrides = nometalmaterial,
	DefaultResistance = RESISTANCE_METAL,
	SolidBase=true,
	Callback=function(pl, ent)
		if util.TraceLine({start=ent:GetPos(), endpos=ent:GetPos() + Vector(0,0,256), mask=MASK_SOLID, filter = ent}).Hit then
			pl:PrintMessage(HUD_PRINTTALK, "Not enough head room to deploy here.")
			return true
		end

		if ents.FindByClass("info_novehicles")[1] then
			pl:PrintMessage(HUD_PRINTTALK, "Vehicles are disabled in this map.")
			return true
		end
	end,
	NoWater = true
})

--[[table.insert(PROPTYPES, {
	Name="Anti-Projectile Tower",
	Group="Powered Deployables",
	Model=Model("models/props_c17/substation_circuitbreaker01a.mdl"),
	Type="prop_antiprojectiletower",
	PHealth=1000,
	TeamMax=3,
	SolidBase=true,
	ClusterPrevention=1,
	MaterialOverrides = nometalmaterial,
	DefaultResistance = RESISTANCE_ELECTRONIC,
	NoWater = true
})]]

table.insert(PROPTYPES, {
	Name="Anchor Beacon",
	Group="Powered Deployables",
	Model=Model("models/props_wasteland/buoy01.mdl"),
	Type="prop_anchorbeacon",
	PHealth=1000,
	TeamMax=3,
	SolidBase=true,
	ClusterPrevention=1,
	MaterialOverrides = nometalmaterial,
	DefaultResistance = RESISTANCE_ELECTRONIC,
	NoWater = true
})

table.insert(PROPTYPES, {
	Name="Magnetic Disruptor Beam Tower",
	Group="Powered Deployables",
	Model=Model("models/props_combine/CombineThumper002.mdl"),
	Type="prop_mdbtower",
	PHealth=1000,
	TeamMax=2,
	SolidBase=true,
	ClusterPrevention=1,
	MaterialOverrides = nometalmaterial,
	DefaultResistance = RESISTANCE_ELECTRONIC,
	NoWater = true
})


table.insert(PROPTYPES, {
	Name="Magus Shield",
	Group="Powered Deployables",
	Model=Model("models/props_c17/substation_stripebox01a.mdl"),
	Type="prop_magusshield",
	PHealth=750,
	Max=1,
	TeamMax=1,
	SolidBase=true,
	ClusterPrevention=2,
	MaterialOverrides = nometalmaterial,
	DefaultResistance = RESISTANCE_ELECTRONIC,
	NoWater = true,
	Callback=function(pl, ent) pl:PrintMessage(HUD_PRINTTALK, "Absorbs 85% damage dealt to normal props in a wide area. If it has no Mana income, it will use its own health. It also acts as its OWN capacitor.") end
})

table.insert(PROPTYPES, {
	Name="Prop Repairer",
	Group="Powered Deployables",
	Model=Model("models/props_junk/TrafficCone001a.mdl"),
	Type="prop_reenforcer",
	PHealth=200,
	Max=5,
	TeamMax=20,
	ClusterPrevention=2,
	MaterialOverrides = nometalmaterial,
	DefaultResistance = RESISTANCE_ELECTRONIC,
	Callback=function(pl, ent) pl:PrintMessage(HUD_PRINTTALK, "Point this at a prop and it will repair it over time.") end,
	NoWater = true
})

table.insert(PROPTYPES, {
	Name="Fire Mine",
	Group="Deployables",
	Model=Model("models/props_combine/combine_mine01.mdl"),
	Type="prop_firemine",
	Max=10,
	TeamMax=40,
	SolidBase=true,
	CountsTowards="mines",
	PHealth=150,
	MaterialOverrides = nometalmaterial,
	DefaultResistance = RESISTANCE_ELECTRONIC,
	NoWater = true
})

table.insert(PROPTYPES, {
	Name="Ice Mine",
	Group="Deployables",
	Model=Model("models/props_combine/combine_mine01.mdl"),
	Type="prop_icemine",
	Max=10,
	TeamMax=40,
	SolidBase=true,
	CountsTowards="mines",
	PHealth=150,
	MaterialOverrides = nometalmaterial,
	DefaultResistance = RESISTANCE_ELECTRONIC,
	NoWater = true
})

table.insert(PROPTYPES, {
	Name="Shock Mine",
	Group="Deployables",
	Model=Model("models/props_combine/combine_mine01.mdl"),
	Type="prop_shockmine",
	Max=10,
	TeamMax=40,
	SolidBase=true,
	CountsTowards="mines",
	PHealth=150,
	MaterialOverrides = nometalmaterial,
	DefaultResistance = RESISTANCE_ELECTRONIC,
	NoWater = true
})

table.insert(PROPTYPES, {
	Name="Poison Mine",
	Group="Deployables",
	Model=Model("models/props_combine/combine_mine01.mdl"),
	Type="prop_poisonmine",
	Max=10,
	TeamMax=40,
	SolidBase=true,
	CountsTowards="mines",
	PHealth=150,
	MaterialOverrides = nometalmaterial,
	DefaultResistance = RESISTANCE_ELECTRONIC,
	NoWater = true
})

table.insert(PROPTYPES, {
	Name="Jump Pad",
	Group="Deployables",
	Model=Model("models/props_c17/lamp_standard_off01.mdl"),
	Type="prop_jumppad",
	Max=5,
	SolidBase=true,
	TeamMax=20,
	PHealth=150,
	MaterialOverrides = nometalmaterial,
	DefaultResistance = RESISTANCE_ELECTRONIC,
	NoWater = true
})

table.insert(PROPTYPES, {
	Name="Health Dispenser",
	Group="Deployables",
	Model=Model("models/props_combine/health_charger001.mdl"),
	Type="prop_healthdispenser",
	Max=3,
	TeamMax=12,
	PHealth=200,
	MaterialOverrides = nometalmaterial,
	DefaultResistance = RESISTANCE_ELECTRONIC
})

table.insert(PROPTYPES, {
	Name="Auto-Turret",
	Group="Powered Deployables",
	Model=Model("models/Combine_turrets/Floor_turret.mdl"),
	Type="prop_turret",
	Max=2,
	TeamMax=6,
	PHealth=250,
	MaterialOverrides = nometalmaterial,
	DefaultResistance = RESISTANCE_ELECTRONIC,
	NoWater = true
})

table.insert(PROPTYPES, {
	Name="Auto-Turret",
	Group="Auto-Turret Barrels",
	Model=Model("models/Combine_turrets/Floor_turret.mdl"),
	Type="prop_turret",
	Max=2,
	TeamMax=6,
	PHealth=250,
	MaterialOverrides = nometalmaterial,
	DefaultResistance = RESISTANCE_ELECTRONIC,
	NoWater = true
})

table.insert(PROPTYPES, {
	Name="Auto-Turret Barrel: Plasma",
	Group="Auto-Turret Barrels",
	Model=Model("models/Items/item_item_crate.mdl"),
	Type="prop_turretbarrel_plasma",
	PHealth=50,
	MaterialOverrides = nometalmaterial,
	DefaultResistance = RESISTANCE_ELECTRONIC
})

table.insert(PROPTYPES, {
	Name="Auto-Turret Barrel: Slow",
	Group="Auto-Turret Barrels",
	Model=Model("models/Items/item_item_crate.mdl"),
	Type="prop_turretbarrel_slow",
	PHealth=50,
	MaterialOverrides = nometalmaterial,
	DefaultResistance = RESISTANCE_ELECTRONIC
})

table.insert(PROPTYPES, {
	Name="Auto-Turret Barrel: Missiles of Magic",
	Group="Auto-Turret Barrels",
	Model=Model("models/Items/item_item_crate.mdl"),
	Type="prop_turretbarrel_magicmissiles",
	PHealth=50,
	MaterialOverrides = nometalmaterial,
	DefaultResistance = RESISTANCE_ELECTRONIC
})

table.insert(PROPTYPES, {
	Name="Auto-Turret Barrel: Pulse Cannon",
	Group="Auto-Turret Barrels",
	Model=Model("models/Items/item_item_crate.mdl"),
	Type="prop_turretbarrel_pulse",
	PHealth=50,
	MaterialOverrides = nometalmaterial,
	DefaultResistance = RESISTANCE_ELECTRONIC
})

table.insert(PROPTYPES, {
	Name="Mountable Turret",
	Group="Powered Deployables",
	Model=Model("models/props_combine/combine_mortar01b.mdl"),
	Type="prop_mountableturret",
	PHealth=400,
	Max = 2,
	TeamMax = 8,
	MaterialOverrides = nometalmaterial,
	DefaultResistance = RESISTANCE_ELECTRONIC,
	NoWater = true
})

table.insert(PROPTYPES, {
	Name="Mountable Turret",
	Group="Mountable Turret Barrels",
	Model=Model("models/props_combine/combine_mortar01b.mdl"),
	Type="prop_mountableturret",
	PHealth=400,
	Max = 2,
	TeamMax = 8,
	MaterialOverrides = nometalmaterial,
	DefaultResistance = RESISTANCE_ELECTRONIC,
	NoWater = true
})

table.insert(PROPTYPES, {
	Name="Mountable Turret Barrel: Plasma",
	Group="Mountable Turret Barrels",
	Model=Model("models/Items/ammoCrate_Rockets.mdl"),
	Type="prop_mturretbarrel_plasma",
	PHealth=50,
	MaterialOverrides = nometalmaterial,
	DefaultResistance = RESISTANCE_ELECTRONIC
})

table.insert(PROPTYPES, {
	Name="Mountable Turret Barrel: Lock-on Missiles",
	Group="Mountable Turret Barrels",
	Model=Model("models/Items/ammoCrate_Rockets.mdl"),
	Type="prop_mturretbarrel_lockons",
	PHealth=50,
	MaterialOverrides = nometalmaterial,
	DefaultResistance = RESISTANCE_ELECTRONIC
})

table.insert(PROPTYPES, {
	Name="Mountable Turret Barrel: Mortar",
	Group="Mountable Turret Barrels",
	Model=Model("models/Items/ammoCrate_Rockets.mdl"),
	Type="prop_mturretbarrel_mortar",
	PHealth=50,
	MaterialOverrides = nometalmaterial,
	DefaultResistance = RESISTANCE_ELECTRONIC
})

table.insert(PROPTYPES, {
	Name="Force Field Door",
	Group="Deployables",
	Model=Model("models/props_wasteland/interior_fence003e.mdl"),
	Type="prop_forcefielddoor",
	Max = 2,
	TeamMax = 8,
	PHealth=400,
	MaterialOverrides = nometalmaterial,
	DefaultResistance = RESISTANCE_ELECTRONIC
})
