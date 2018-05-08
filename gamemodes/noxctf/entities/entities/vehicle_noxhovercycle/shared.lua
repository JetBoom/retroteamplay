RegisterVehicle("Hover Cycle", {
	Class = "vehicle_noxhovercycle",
	Model = "models/props_combine/headcrabcannister01a.mdl",
	Name = "Hover Cycle",
	Description = "A one-person fast attack vehicle with a rapid-firing Heater cannon.",
	CreationOffset = Vector(0, 0, 32),
	StocksPerTeam = 2,
	Icon = "spellicons/vehicle_noxhovercycle3.png",
	HoverVehicle = true,
	ManaToSpawn = 200,
	RespawnTime = 120
})

ENT.Type = "anim"

ENT.Name = "Hover Cycle"
ENT.Model = Model("models/props_combine/headcrabcannister01a.mdl")
ENT.MaxHealth = 150
ENT.CreationOffset = Vector(0, 0, 32)
ENT.ScriptVehicle = true
ENT.NoProtectSeats = true

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
	return self:GetNetworkedInt("teamid", -1)
end

function ENT:SetTeam(__int__)
	self:SetNetworkedInt("teamid", __int__)
	self.TeamID = __int__
	local c = team.GetColor(__int__)
	self.PilotSeat:SetColor(Color(c.r, c.g, c.b, 255))
end

function ENT:Alive() return 0 < self:GetVHealth() end

ENT.SetTeamID = ENT.SetTeam

function ENT:EyePos()
	return self:GetPos()
end
