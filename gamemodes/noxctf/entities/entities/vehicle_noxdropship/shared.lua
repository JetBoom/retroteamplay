RegisterVehicle("Dropship", {
	Class = "vehicle_noxdropship",
	Model = "models/combine_dropship_container.mdl",
	Name = "Dropship",
	Description = "A massive air vehicle that can hold three active gunners and four passengers.",
	CreationOffset = Vector(0, 0, 0),
	StocksPerTeam = 1,
	Icon = "spellicons/vehicle_noxdropship.png",
	AirVehicle = true,
	ManaToSpawn = 500,
	RespawnTime = 300
})

ENT.Type = "anim"

ENT.Name = "Dropship"
ENT.Model = Model("models/combine_dropship_container.mdl")
ENT.MaxHealth = 800
ENT.CreationOffset = Vector(0, 0, 0)
ENT.ScriptVehicle = true
ENT.IsAirVehicle = true
ENT.NoProtectSeats = true

util.PrecacheSound("vehicles/v8/vehicle_impact_heavy1.wav")
util.PrecacheSound("vehicles/v8/vehicle_impact_heavy2.wav")
util.PrecacheSound("vehicles/v8/vehicle_impact_heavy3.wav")
util.PrecacheSound("vehicles/v8/vehicle_impact_heavy4.wav")
util.PrecacheSound("NPC_CombineGunship.CannonSound")
util.PrecacheSound("NPC_CombineGunship.CannonStartSound")
util.PrecacheSound("NPC_CombineGunship.CannonStopSound")
util.PrecacheSound("NPC_CombineGunship.RotorSound")
util.PrecacheSound("NPC_CombineGunship.PatrolPing")

util.PrecacheSound("npc/combine_gunship/ping_patrol.wav")
util.PrecacheSound("npc/combine_gunship/attack_stop2.wav")
util.PrecacheSound("npc/combine_gunship/attack_start2.wav")
util.PrecacheSound("npc/combine_gunship/gunship_explode2.wav")
util.PrecacheSound("npc/combine_gunship/gunship_weapon_fire_loop6.wav")
util.PrecacheSound("npc/combine_gunship/engine_whine_loop1.wav")

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
	local col = team.GetColor(__int__)
	local r, g, b = col.r, col.g, col.b
	self.PilotSeat:SetColor(Color(r, g, b, 255))
	self.LeftGunnerSeat:SetColor(Color(r, g, b, 255))
	self.RightGunnerSeat:SetColor(Color(r, g, b, 255))
	self.LeftPassengerSeat1:SetColor(Color(r, g, b, 255))
	self.LeftPassengerSeat2:SetColor(Color(r, g, b, 255))
	self.RightPassengerSeat1:SetColor(Color(r, g, b, 255))
	self.RightPassengerSeat2:SetColor(Color(r, g, b, 255))
end

function ENT:Alive() return 0 < self:GetVHealth() end

ENT.SetTeamID = ENT.SetTeam

function ENT:EyePos()
	return self:GetPos()
end
