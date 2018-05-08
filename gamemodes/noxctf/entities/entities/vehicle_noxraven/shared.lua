RegisterVehicle("Raven Light Fighter", {
	Class = "vehicle_noxraven",
	Model = "models/props_combine/headcrabcannister01a.mdl",
	Name = "Raven Light Fighter",
	Description = "A one-man air fighter with dual lock-on missiles and a mana shard launcher.",
	CreationOffset = Vector(0, 0, 5),
	StocksPerTeam = 2,
	Icon = "spellicons/vehicle_noxraven.png",
	AirVehicle = true,
	ManaToSpawn = 200,
	RespawnTime = 90
})

ENT.Type = "anim"

ENT.Name = "Raven Light Fighter"
ENT.Model = Model("models/props_combine/headcrabcannister01a.mdl")
ENT.MaxHealth = 250
ENT.CreationOffset = Vector(0, 0, 5)
ENT.ScriptVehicle = true
ENT.IsAirVehicle = true
ENT.NoProtectSeats = true

util.PrecacheSound("vehicles/v8/vehicle_impact_heavy1.wav")
util.PrecacheSound("vehicles/v8/vehicle_impact_heavy2.wav")
util.PrecacheSound("vehicles/v8/vehicle_impact_heavy3.wav")
util.PrecacheSound("vehicles/v8/vehicle_impact_heavy4.wav")
util.PrecacheSound("npc/strider/strider_minigun2.wav")

function ENT:GetThrust()
	return self:GetNetworkedFloat("thrust", 0)
end

function ENT:GetAfterBurner()
	return self:GetNetworkedFloat("afterburner", 0)
end

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
	if SERVER then
		if self.LWTrail and self.LWTrail:IsValid() then
			self.LWTrail:Remove()
		end
		if self.RWTrail and self.RWTrail:IsValid() then
			self.RWTrail:Remove()
		end

		self.LWTrail = util.SpriteTrail(self.LeftStub, 0, col, false, 18, 14, 0.75, 0.02, "trails/smoke.vmt")
		self.RWTrail = util.SpriteTrail(self.RightStub, 0, col, false, 18, 14, 0.75, 0.02, "trails/smoke.vmt")
	end
end

function ENT:Alive() return 0 < self:GetVHealth() end

ENT.SetTeamID = ENT.SetTeam
