RegisterVehicle("Assault Rover", {
	Class = "vehicle_noxbase",
	Name = "Assault Rover",
	Model = "models/props_vehicles/car002a_physics.mdl",
	Description = "This armored, two-man ground vehicle has a roof-mounted cannon designed for base onslaughts.",
	CreationOffset = Vector(0, 0, 60),
	StocksPerTeam = 2,
	Icon = "spellicons/vehicle_noxbase.png",
	GroundVehicle = true,
	ManaToSpawn = 200,
	RespawnTime = 120
})

ENT.Type = "anim"

ENT.Name = "Assault Rover"
ENT.Model = Model("models/props_vehicles/car002a_physics.mdl")
ENT.MaxHealth = 400
ENT.CreationOffset = Vector(0, 0, 60)
ENT.ScriptVehicle = true
ENT.NoProtectSeats = true

util.PrecacheModel("models/props_vehicles/carparts_axel01a.mdl")
util.PrecacheModel("models/props_vehicles/carparts_door01a.mdl")
util.PrecacheModel("models/props_vehicles/carparts_door01a.mdl")
util.PrecacheModel("models/props_vehicles/carparts_muffler01a.mdl")
util.PrecacheModel("models/props_c17/pulleywheels_large01.mdl")
util.PrecacheModel("models/props_c17/trappropeller_engine.mdl")
util.PrecacheModel("models/props_borealis/bluebarrel001.mdl")
util.PrecacheSound("vehicles/v8/v8_stop1.wav")
util.PrecacheSound("vehicles/Airboat/pontoon_impact_hard1.wav")
util.PrecacheSound("ambient/machines/catapult_throw.wav")

function ENT:GetVHealth()
	return self:GetDTInt(0)
end
ENT.VHealth = ENT.GetVHealth

function ENT:SetVHealth(health)
	self:SetDTInt(0, math.floor(health))
end

function ENT:GetMaxVHealth()
	return self.MaxHealth
end

function ENT:Team()
	return self:GetDTInt(1)
end

function ENT:SetTeam(teamid)
	self:SetDTInt(1, teamid)
	if SERVER then
		self.TeamID = teamid
		local col = team.GetColor(teamid)
		self:GetPilotSeat():SetColor(Color(col.r, col.g, col.b, 0))
		self:GetGunnerSeat():SetColor(Color(col.r, col.g, col.b, 255))
	end
end

function ENT:GetState(state)
	return self:GetDTInt(2)
end

function ENT:SetState(state)
	self:SetDTInt(2, state)
end

function ENT:EyePos()
	return self:GetPos()
end

function ENT:SetPilotSeat(ent)
	self:SetDTEntity(0, ent)
end

function ENT:GetPilotSeat()
	return self:GetDTEntity(0)
end

function ENT:SetGunnerSeat(ent)
	self:SetDTEntity(1, ent)
end

function ENT:GetGunnerSeat()
	return self:GetDTEntity(1)
end

function ENT:SetCannon(ent)
	self:SetDTEntity(2, ent)
end

function ENT:GetCannon()
	return self:GetDTEntity(2)
end

function ENT:Alive() return 0 < self:GetHealth() end

ENT.SetTeamID = ENT.SetTeam

STATE_ROVER_OFF = 0
STATE_ROVER_IDLE = 1
STATE_ROVER_ACCELERATING = 2

local EngineStart = Sound("ATV_engine_start")
local EngineIdleSlow = Sound("ATV_throttleoff_slowspeed")
local EngineIdle = Sound("ATV_throttleoff_fastspeed")
local EngineForward = Sound("ATV_reverse")
