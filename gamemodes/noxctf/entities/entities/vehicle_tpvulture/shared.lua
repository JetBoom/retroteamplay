ENT.Type = "anim"
ENT.Base = "vehicle_tp_base_air"

ENT.ScriptVehicle = true
ENT.IsAirVehicle = true

ENT.Name = "Vulture Heavy Bomber"
ENT.Model = Model("models/Gibs/helicopter_brokenpiece_06_body.mdl")
ENT.Description = "Two man bomber that can decimate bases."
ENT.Icon = "spellicons/vehicle_noxvulture"

ENT.CreationOffset = Vector(0, 0, 128)

ENT.MaxHealth = 400
ENT.Stocks = 1
ENT.RespawnTime = 5
ENT.ManaToSpawn = 350

ENT.ThirdPersonCamera = Vector(-400, 0, 0)

ENT.Mass = 1500

ENT.MaxSpeed = 1150
ENT.MaxAcceleration = 1600
ENT.AccelerationRate = 600
ENT.DeaccelerationRate = 1400
ENT.DampingFactor = 0.5
ENT.InactiveDampingFactor = 0.1
ENT.HoverSpeed = 240
ENT.HoverHeight = 132
ENT.HoverForce = 512
ENT.TurnSpeed = 0.5

ENT.RollSpeed = 100

ENT.CollisionDamageScale = 0.04
ENT.CrashSpeed = 900
ENT.CollisionDamageSpeed = 300
ENT.ExplosionRadius = 420
ENT.ExplosionDamage = 0.4

ENT.BombVelocity = ENT.MaxSpeed * 0.5
ENT.BombZ = 0.6
ENT.HomingMissileDelay = 2.5
ENT.BombDelay = 1.75
ENT.FlareDelay = 5

ENT.FlakCannonDelay = 1

ENT.VehicleParts = {
	PilotSeat = {
		Class = "prop_vehicle_prisoner_pod",
		Model = Model("models/props_phx/carseat2.mdl"),
		KeyValues = {
			"solid", "6",
			"vehiclescript", "scripts/vehicles/prisoner_pod.txt"
		},
		Pos = Vector(75, 0, 18),
		Angles = Angle(0, 270, 0),
		Mass = 100,
		Gravity = false,
		Drag = false,
		PilotSeat = true
	},
	TailGunnerSeat = {
		Class = "prop_vehicle_prisoner_pod",
		Model = Model("models/props_phx/carseat2.mdl"),
		KeyValues = {
			"solid", "6",
			"vehiclescript", "scripts/vehicles/prisoner_pod.txt"
		},
		Pos = Vector(-85, 0, -75),
		Angles = Angle(0, 90, 0),
		Mass = 100,
		Gravity = false,
		Drag = false,
		GunnerSeat = true
	},
	RightWing = {
		Class = "vehiclepart",
		Model = Model("models/props_combine/combine_barricade_med02a.mdl"),
		Pos = Vector(-50, -50, 0),
		Angles = Angle(-90, -90, 180),
		Mass = 100,
		Gravity = false,
		Drag = false
	},
	LeftWing = {
		Class = "vehiclepart",
		Model = Model("models/props_combine/combine_barricade_med02a.mdl"),
		Pos = Vector(-50, 50, 0),
		Angles = Angle(270, 180, 90),
		Mass = 100,
		Gravity = false,
		Drag = false
	},
	Tail = {
		Class = "vehiclepart",
		Model = Model("models/gibs/helicopter_brokenpiece_05_tailfan.mdl"),
		Pos = Vector(-190, 0, 25),
		Angles = Angle(20, 0, 0),
		Mass = 100,
		Gravity = false,
		Drag = false
	}
}
ENT.VehicleConstraints = {
	{"Weld", "*self*", "RightWing", 0, 0, 0, 1},
	{"Weld", "*self*", "LeftWing", 0, 0, 0, 1},
	{"Weld", "*self*", "Tail", 0, 0, 0, 1},
	{"Weld", "*self*", "PilotSeat", 0, 0, 0, 1},
	{"Weld", "*self*", "TailGunnerSeat", 0, 0, 0, 1},
	{"Weld", "LeftWing", "RightWing", 0, 0, 0, 1}
}

util.PrecacheSound("npc/attack_helicopter/aheli_mine_drop1.wav")
util.PrecacheSound("ambient/machines/laundry_machine1_amb.wav")

function ENT:SetGunnerSeat(ent)
	self:SetDTEntity(1, ent)
	self.GunnerSeat = ent
end

function ENT:GetGunnerSeat()
	local ent = self:GetDTEntity(1)
	if ent:IsValid() then return ent end

	return self.GunnerSeat or NULL
end
