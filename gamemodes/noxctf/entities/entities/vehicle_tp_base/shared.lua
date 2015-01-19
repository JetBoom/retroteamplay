ENT.Type = "anim"

ENT.ScriptVehicle = true

ENT.NoProtectSeats = false

ENT.Name = "Unnamed Vehicle"
ENT.Description = "A descriptionless vehicle."
ENT.Model = Model("models/props_combine/headcrabcannister01a.mdl")
ENT.Icon = "spellicons/vehicle_noxraven"

ENT.CreationOffset = Vector(0, 0, 0)

ENT.MaxHealth = 200
ENT.Stocks = 0
ENT.ManaToSpawn = 100
ENT.RespawnTime = 60

ENT.Mass = 1500

ENT.CollisionDamageScale = 0
ENT.CrashSpeed = 900
ENT.CollisionDamageSpeed = 250
ENT.SkyBoxBounceBack = false
ENT.ExplosionRadius = 320
ENT.ExplosionDamage = 0.5

ENT.VehicleParts = {}
ENT.VehicleConstraints = {}

function ENT:GetVHealth()
	return self:GetDTInt(0)
end

function ENT:SetVHealth(health)
	self:SetDTInt(0, health)
end

function ENT:GetMaxVHealth()
	return self.MaxHealth
end

function ENT:Alive()
	return 0 < self:GetVHealth()
end

function ENT:Team()
	return self:GetDTInt(1)
end

function ENT:SetTeam(teamid)
	self:SetDTInt(1, teamid)

	if SERVER then
		for _, ent in pairs(ents.FindByClass("prop_vehicle*")) do
			if ent:GetVehicleParent() == self then
				ent:SetColor(team.GetColor(teamid))
			end
		end

		self:TeamSet(teamid)
	end
end
ENT.SetTeamID = ENT.SetTeam

function ENT:SetPilotSeat(ent)
	self:SetDTEntity(0, ent)
	self.PilotSeat = ent
end

function ENT:GetPilotSeat()
	local ent = self:GetDTEntity(0)
	if ent:IsValid() then return ent end

	return self.PilotSeat or NULL
end

function ENT:GetPilot()
	local seat = self:GetPilotSeat()
	if seat:IsValid() then
		return seat:GetDriver()
	end

	return NULL
end
ENT.GetDriver = ENT.GetPilot

util.PrecacheSound("vehicles/v8/vehicle_impact_heavy1.wav")
util.PrecacheSound("vehicles/v8/vehicle_impact_heavy2.wav")
util.PrecacheSound("vehicles/v8/vehicle_impact_heavy3.wav")
util.PrecacheSound("vehicles/v8/vehicle_impact_heavy4.wav")
