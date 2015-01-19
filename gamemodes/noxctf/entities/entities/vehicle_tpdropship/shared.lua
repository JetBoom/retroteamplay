ENT.Type = "anim"

ENT.ScriptVehicle = true
ENT.IsAirVehicle = true

ENT.Name = "Juggernaut Dropship"
ENT.Description = "A massive air vehicle that can hold three active gunners and four passengers."
ENT.Model = Model("models/combine_dropship_container.mdl")
ENT.Icon = "spellicons/vehicle_noxdropship"

ENT.MaxHealth = 800
ENT.Stocks = 1
ENT.ManaToSpawn = 500
ENT.RespawnTime = 300

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
	local col = team.GetColor(teamid)
	self.PilotSeat:SetColor(col)
	self.LeftGunnerSeat:SetColor(col)
	self.RightGunnerSeat:SetColor(col)
	self.LeftPassengerSeat1:SetColor(col)
	self.LeftPassengerSeat2:SetColor(col)
	self.RightPassengerSeat1:SetColor(col)
	self.RightPassengerSeat2:SetColor(col)
end

function ENT:Alive() return 0 < self:GetVHealth() end

ENT.SetTeamID = ENT.SetTeam

function ENT:EyePos()
	return self:GetPos()
end

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
