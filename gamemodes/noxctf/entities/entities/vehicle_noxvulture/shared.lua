RegisterVehicle("Vulture Heavy Bomber", {
	Class = "vehicle_noxvulture",
	Model = "models/Gibs/helicopter_brokenpiece_06_body.mdl",
	Name = "Vulture Heavy Bomber",
	Description = "Two man bomber that can decimate bases.",
	CreationOffset = Vector(0, 0, 50),
	StocksPerTeam = 1,
	Icon = "spellicons/vehicle_noxvulture.png",
	AirVehicle = true,
	RespawnTime = 180,
	ManaToSpawn = 350
})

ENT.Type = "anim"

ENT.Name = "Vulture Heavy Bomber"
ENT.Model = Model("models/Gibs/helicopter_brokenpiece_06_body.mdl")
ENT.MaxHealth = 400
ENT.CreationOffset = Vector(0, 0, 50)
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
	self.TailGunnerSeat:SetColor(Color(c.r, c.g, c.b, 255))
	if SERVER then
		if self.LWTrail and self.LWTrail:IsValid() then
			self.LWTrail:Remove()
		end
		if self.RWTrail and self.RWTrail:IsValid() then
			self.RWTrail:Remove()
		end

		self.LWTrail = util.SpriteTrail(self.LeftWing, 0, col, false, 18, 15, 0.75, 0.02, "trails/smoke.vmt")
		self.RWTrail = util.SpriteTrail(self.RightWing, 0, col, false, 18, 15, 0.75, 0.02, "trails/smoke.vmt")
	end
end

function ENT:Alive() return 0 < self:GetVHealth() end

ENT.SetTeamID = ENT.SetTeam

function ENT:EyePos()
	return self:GetPos()
end
