ENT.Type = "anim"

ENT.ScriptVehicle = true
ENT.HoverVehicle = true
ENT.NoProtectSeats = true

ENT.Name = "Hover Cycle"
ENT.Model = Model("models/props_combine/headcrabcannister01a.mdl")
ENT.Description = "A one-person fast attack vehicle with a rapid-firing Heater cannon."
ENT.Icon = "spellicons/vehicle_noxhovercycle3"

ENT.CreationOffset = Vector(0, 0, 32)

ENT.MaxHealth = 150
ENT.Stocks = 2
ENT.ManaToSpawn = 200
ENT.RespawnTime = 120

util.PrecacheSound("Weapon_SMG1.NPC_Single")

function ENT:GetVHealth()
	return self:GetNetworkedInt("health")
end

function ENT:SetVHealth(__int__)
	self:SetNetworkedInt("health", math.floor(__int__))
end

function ENT:GetMaxVHealth()
	return self.MaxHealth
end

function ENT:Team()
	return self:GetNetworkedInt("teamid", 0)
end

function ENT:SetTeam(teamid)
	self:SetNetworkedInt("teamid", teamid)
	self.PilotSeat:SetColor(team.GetColor(teamid))
end

function ENT:Alive() return 0 < self:GetVHealth() end

ENT.SetTeamID = ENT.SetTeam

function ENT:EyePos()
	return self:GetPos()
end
