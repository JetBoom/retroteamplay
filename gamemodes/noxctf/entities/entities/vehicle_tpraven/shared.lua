ENT.Type = "anim"
ENT.Base = "vehicle_tp_base_air"

ENT.ScriptVehicle = true
ENT.IsAirVehicle = true

ENT.Name = "Raven Light Fighter"
ENT.Description = "A one-man air fighter with lock-on missiles and a mana shard launcher."
ENT.Model = Model("models/props_combine/headcrabcannister01a.mdl")
ENT.Icon = "spellicons/vehicle_noxraven"

ENT.CreationOffset = Vector(0, 0, 50)

ENT.ThirdPersonCamera = Vector(-200, 0, 64)

ENT.MaxHealth = 200
ENT.Stocks = 2
ENT.ManaToSpawn = 200
ENT.RespawnTime = 90

ENT.Mass = 1500

ENT.MaxSpeed = 1200
ENT.MaxAcceleration = 1800
ENT.AccelerationRate = 600
ENT.DeaccelerationRate = 1600
ENT.DampingFactor = 0.5
ENT.InactiveDampingFactor = 0.15
ENT.HoverSpeed = 240
ENT.HoverHeight = 90
ENT.HoverForce = 512
ENT.TurnSpeed = 0.73

ENT.RollSpeed = 150

ENT.CollisionDamageScale = 0.04
ENT.CrashSpeed = 900
ENT.CollisionDamageSpeed = 250
ENT.ExplosionRadius = 390
ENT.ExplosionDamage = 0.3

ENT.PhotonCannonDamage = 15
ENT.PhotonCannonDelay = 0.33

ENT.HomingMissileDelay = 2.5

ENT.AirMineDelay = 3

ENT.VehicleParts = {
	PilotSeat = {
		Class = "prop_vehicle_prisoner_pod",
		Model = Model("models/props_phx/carseat2.mdl"),
		KeyValues = {
			"solid", "6",
			"vehiclescript", "scripts/vehicles/prisoner_pod.txt"
		},
		Pos = Vector(-16, 0, 24),
		Angles = Angle(0, 270, 0),
		Mass = 100,
		Gravity = false,
		Drag = false,
		PilotSeat = true
	},
	RightWing = {
		Class = "vehiclepart",
		Model = Model("models/gibs/helicopter_brokenpiece_05_tailfan.mdl"),
		Pos = Vector(-32, -90, 0),
		Angles = Angle(0, 60, -90),
		Mass = 100,
		Gravity = false,
		Drag = false
	},
	RightStub = {
		Class = "vehiclepart",
		Model = Model("models/props_combine/headcrabcannister01a.mdl"),
		Pos = Vector(-32, -90, 0),
		Angles = Angle(0, 0, 0),
		Mass = 100,
		Gravity = false,
		Drag = false
	},
	LeftWing = {
		Class = "vehiclepart",
		Model = Model("models/gibs/helicopter_brokenpiece_05_tailfan.mdl"),
		Pos = Vector(-32, 90, 0),
		Angles = Angle(0, -60, 90),
		Mass = 100,
		Gravity = false,
		Drag = false
	},
	LeftStub = {
		Class = "vehiclepart",
		Model = Model("models/props_combine/headcrabcannister01a.mdl"),
		Pos = Vector(-32, 90, 0),
		Angles = Angle(0, 0, 0),
		Mass = 100,
		Gravity = false,
		Drag = false
	}
}
ENT.VehicleConstraints = {
	{"Weld", "*self*", "RightWing", 0, 0, 0, 1},
	{"Weld", "*self*", "LeftWing", 0, 0, 0, 1},
	{"Weld", "RightWing", "RightStub", 0, 0, 0, 1},
	{"Weld", "LeftWing", "LeftStub", 0, 0, 0, 1},
	{"Weld", "*self*", "PilotSeat", 0, 0, 0, 1},
	{"Weld", "LeftWing", "RightWing", 0, 0, 0, 1},
	{"NoCollide", "PilotSeat", "RightWing", 0, 0},
	{"NoCollide", "PilotSeat", "LeftWing", 0, 0}
}

util.PrecacheSound("npc/strider/strider_minigun2.wav")
