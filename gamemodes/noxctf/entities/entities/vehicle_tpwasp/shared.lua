ENT.Type = "anim"
ENT.Base = "vehicle_tp_base_air"

ENT.ScriptVehicle = true
ENT.IsAirVehicle = true
ENT.NoProtectSeats = true

ENT.Name = "Wasp Scout Flyer"
ENT.Model = Model("models/props_combine/headcrabcannister01a.mdl")
ENT.Description = "A one-man scout craft with a light mana shard launcher."
ENT.Icon = "spellicons/vehicle_noxwasp"

ENT.CreationOffset = Vector(0, 0, 50)

ENT.ThirdPersonCamera = Vector(-200, 0, 64)

ENT.MaxHealth = 150
ENT.Stocks = 2
ENT.ManaToSpawn = 125
ENT.RespawnTime = 90

ENT.Mass = 800

ENT.MaxSpeed = 1400
ENT.MaxAcceleration = 1900
ENT.AccelerationRate = 700
ENT.DeaccelerationRate = 1900
ENT.DampingFactor = 0.5
ENT.InactiveDampingFactor = 0.1
ENT.HoverSpeed = 240
ENT.HoverHeight = 90
ENT.HoverForce = 512
ENT.TurnSpeed = 0.78

ENT.RollSpeed = 150

ENT.CollisionDamageScale = 0.04
ENT.CrashSpeed = 900
ENT.CollisionDamageSpeed = 250
ENT.ExplosionRadius = 256
ENT.ExplosionDamage = 0.2

ENT.PhotonCannonDamage = 15
ENT.PhotonCannonDelay = 0.25

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
		Model = Model("models/Gibs/helicopter_brokenpiece_03.mdl"),
		Pos = Vector(-15, -42, 0),
		Angles = Angle(0, 100, -140),
		Mass = 100,
		Gravity = false,
		Drag = false
	},
	LeftWing = {
		Class = "vehiclepart",
		Model = Model("models/Gibs/helicopter_brokenpiece_03.mdl"),
		Pos = Vector(-15, 42, 0),
		Angles = Angle(0, -100, 30),
		Mass = 100,
		Gravity = false,
		Drag = false
	}
}
ENT.VehicleConstraints = {
	{"Weld", "*self*", "RightWing", 0, 0, 0, 1},
	{"Weld", "*self*", "LeftWing", 0, 0, 0, 1},
	{"Weld", "*self*", "PilotSeat", 0, 0, 0, 1},
	{"NoCollide", "PilotSeat", "RightWing", 0, 0},
	{"NoCollide", "PilotSeat", "LeftWing", 0, 0}
}

function ENT:SetFiring(firing)
	self:SetDTBool(3, firing)
end

function ENT:GetFiring()
	return self:GetDTBool(3)
end

util.PrecacheSound("vehicles/APC/apc_start_loop3.wav")
util.PrecacheSound("NPC_dog.Idlemode_loop")
