ENT.Type = "anim"

ENT.ScriptVehicle = true
ENT.IsGroundVehicle = true

ENT.Name = "Assault Rover"
ENT.Description = "This armored, two-man ground vehicle has a roof-mounted cannon designed for base onslaughts."
ENT.Model = Model("models/props_vehicles/car002a_physics.mdl")
ENT.Icon = "spellicons/vehicle_noxbase"

ENT.Stocks = 2
ENT.ManaToSpawn = 200
ENT.RespawnTime = 120
ENT.MaxHealth = 400

ENT.CreationOffset = Vector(0, 0, 60)

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
		local col = team.GetColor(teamid)
		self:GetPilotSeat():SetColor(col)
		self:GetGunnerSeat():SetColor(col)
	end
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

function ENT:GetPilot()
	local seat = self:GetPilotSeat()
	if seat:IsValid() and seat:IsVehicle() then
		if SERVER then
			return seat:GetDriver()
		else
			return seat:GetOwner()
		end
	end

	return NULL
end
ENT.GetDriver = ENT.GetPilot

function ENT:Alive() return 0 < self:GetHealth() end

ENT.SetTeamID = ENT.SetTeam

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
