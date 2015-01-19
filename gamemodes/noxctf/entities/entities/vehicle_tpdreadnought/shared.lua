ENT.Type = "anim"

ENT.ScriptVehicle = true
ENT.HoverVehicle = true

ENT.Name = "Dreadnought Heavy Tank"
ENT.Model = Model("models/props_vehicles/apc001.mdl")
ENT.Description = "A heavy multi-personal carrier for ground assaults."
ENT.Icon = "spellicons/vehicle_noxhovercycle3"

ENT.MaxHealth = 2100
ENT.Stocks = 1
ENT.ManaToSpawn = 600
ENT.RespawnTime = 360

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
	return self:GetNetworkedInt("teamid", 0)
end

function ENT:SetTeam(teamid)
	self:SetNetworkedInt("teamid", teamid)
	local col = team.GetColor(teamid)
	self.PilotSeat:SetColor(col)
	self.CannonGunnerSeat:SetColor(col)
	self.TailGunnerSeat:SetColor(col)
	self.LeftPassengerSeat:SetColor(col)
	self.RightPassengerSeat:SetColor(col)
	self.RearPassengerSeat1:SetColor(col)
	self.RearPassengerSeat2:SetColor(col)
end

function ENT:SetPilotSeat(ent)
	self:SetDTEntity(1, ent)
end

function ENT:GetPilotSeat()
	return self:GetDTEntity(1)
end

function ENT:SetGunnerSeat(ent)
	self:SetDTEntity(2, ent)
end

function ENT:GetGunnerSeat()
	return self:GetDTEntity(2)
end

function ENT:SetCannonGunnerSeat(ent)
	self:SetDTEntity(3, ent)
end

function ENT:GetCannonGunnerSeat()
	return self:GetDTEntity(3)
end

function ENT:SetCannon(ent)
	self:SetDTEntity(0, ent)
end

function ENT:GetCannon()
	return self:GetDTEntity(0)
end

function ENT:Alive() return 0 < self:GetVHealth() end

ENT.SetTeamID = ENT.SetTeam

function ENT:EyePos()
	return self:GetPos()
end
