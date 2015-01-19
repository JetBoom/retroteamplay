AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/Roller_Spikes.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self.NextCantTakeMsg = 0
	self.LastDrop = 0
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetTrigger(true)
	
	self.Phys = self:GetPhysicsObject()
	if self.Phys:IsValid() then
		self.Phys:SetMass(500)
		self.Phys:EnableMotion(false)
		self.Phys:Wake()
	end

	local teamid = self:GetTeamID()
	local col = team.TeamInfo[teamid].Color
	self:SetColor(Color(col.r, col.g, col.b, 255))
	self.Carriers = {}

	self:SetName(teamid)

	self:SetImmunity(120)
end

function ENT:Dropped(pl)
	local byplayer = "itself"
	if pl and pl:IsValid() then
		pl.Carrying = nil
		byplayer = pl:Name()
	end
	self:SetSolid(SOLID_VPHYSICS)
	self.Phys:EnableGravity(true)
	self:SetCarrier(NULL)
	self.Phys:EnableMotion(true)
	self.Phys:Wake()
	if pl and pl:IsValid() then
		self.Phys:SetVelocityInstantaneous(pl:GetVelocity() * 0.333 + Vector(0, 0, 64))
	end
	self.LastDrop = CurTime()
	self.AutoReturnTimer = CurTime() + 20
	self:SetSkin(2)
	gamemode.Call("FlagDropped", self:GetTeamID(), byplayer)
end

function ENT:Returned(pl, far)
	self.AutoReturnPlayer = nil

	local myteam = self:GetTeamID()
	local flagpoint = team.TeamInfo[myteam].FlagPoint
	if far then
		umsg.Start("FlagReturnEffect")
			umsg.Vector(self:GetPos())
			umsg.Vector(flagpoint)
			umsg.Short(myteam)
		umsg.End()
	end
	self:SetSolid(SOLID_VPHYSICS)
	self:SetPos(flagpoint)
	self:SetCarrier(NULL)
	self.Phys:EnableGravity(true)
	self.Phys:EnableMotion(false)
	self.Phys:Wake()
	self.AutoReturnTimer = nil
	self.AutoReturnPlayer = nil
	self:SetSkin(0)
	if pl and pl:IsValid() then
		GAMEMODE:FlagReturned(pl, myteam, far)
	else
		GAMEMODE:FlagReturned(nil, myteam, far)
	end
end

function ENT:Touch(hitent)
	if ENDGAME then return end

	if hitent:IsPlayer() and hitent:CanTakeFlag(self) and not self:GetCarrier():IsValid() and not hitent:InVehicle() then
		local myteam = self:GetTeamID()
		if hitent:IsCarrying() then
			if hitent:Team() == myteam then
				if self:GetSkin() == 2 then
					local dist = self:GetPos():Distance(team.TeamInfo[myteam].FlagPoint)
					if dist > 512 then
						self:Returned(hitent, true)
						return
					elseif dist > 80 then
						self:Returned(hitent, false)
						return
					end
				elseif self:GetSkin() == 0 then
					local carrier = hitent
					hitent = hitent.Carrying
					local otherteam = hitent:GetTeamID()

					if carrier:IsPlayer() then
						local dist = hitent:GetPos():Distance(team.TeamInfo[myteam].FlagPoint)
						self:SetSolid(SOLID_VPHYSICS)
						self:SetPos(team.TeamInfo[myteam].FlagPoint)
						self:SetCarrier(NULL)
						self.Phys:EnableGravity(true)
						self.Phys:EnableMotion(false)
						self.Phys:Wake()
						self.AutoReturnTimer = nil
						self.AutoReturnPlayer = nil
						self:SetSkin(0)

						hitent:SetSolid(SOLID_VPHYSICS)
						hitent:SetPos(team.TeamInfo[otherteam].FlagPoint)
						hitent:SetCarrier(NULL)
						hitent.Phys:EnableGravity(true)
						hitent.Phys:EnableMotion(false)
						hitent.Phys:Wake()
						hitent.AutoReturnTimer = nil
						hitent.AutoReturnPlayer = nil
						hitent:SetSkin(0)
						carrier.Carrying = nil
						if dist < 200 then
							gamemode.Call("FlagCaptured", carrier, myteam, otherteam)
						end
						self.Carriers = {}
					end
				end
			end
		elseif hitent:Team() ~= myteam and CurTime() >= hitent.LastDeath + 1 and CurTime() >= (hitent.NextFlagPickup or 0) then
			if CurTime() < self:GetImmunity() then
				if self.NextCantTakeMsg < CurTime() then
					hitent:CenterPrint("The flag is currently immune to pickups!", "COLOR_RED")
					self.NextCantTakeMsg = CurTime() + 1
				end
			elseif team.NumPlayers(myteam) > 0 then
				if CurTime() > self.LastDrop + 0.75 then
					self:SetSolid(SOLID_NONE)
					self:SetCarrier(hitent)
					self.Phys:EnableGravity(false)
					self.Phys:EnableMotion(true)
					self.Phys:Wake()
					hitent.Carrying = self
					self:SetSkin(1)
					gamemode.Call("FlagTaken", myteam, hitent)
					self.AutoReturnTimer = nil
					self.AutoReturnPlayer = nil

					hitent:RemoveInvisibility()
				end
			else
				if self.NextCantTakeMsg < CurTime() then
					hitent:CenterPrint("You can't take the flag of an unrepresented team!", "COLOR_RED")
					self.NextCantTakeMsg = CurTime() + 1
				end
			end
		elseif hitent:Team() == myteam and self:GetSkin() == 2 then
			local dist = self:GetPos():Distance(team.TeamInfo[myteam].FlagPoint)
			if dist >= 256 then
				if not self.AutoReturnPlayer then
					self.AutoReturnTimer = CurTime() + CTF_FLAG_RETURNTIME
					self.AutoReturnPlayer = hitent
					GAMEMODE:CenterPrintAll(hitent:Name().." is trying to return the "..team.GetName(myteam).." flag! "..CTF_FLAG_RETURNTIME.." seconds until return.", nil, CTF_FLAG_RETURNTIME)
				end
			elseif dist >= 16 then
				self:Returned(hitent, false)
			end
		end
	end
end

function ENT:Think()
	if self.AutoReturnTimer and self.AutoReturnTimer <= CurTime() then
		self:Returned(self.AutoReturnPlayer, true)
		return
	end

	local carrier = self:GetCarrier()
	if not carrier:IsValid() then return end

	if carrier:IsValid() and carrier:Alive() then
		self:AlignToCarrier()
		self.Carriers[carrier] = (self.Carriers[carrier] or 0) + FrameTime()
		self.Phys:SetVelocityInstantaneous(Vector(0, 0, 0))
	elseif carrier:IsValid() then
		self:Dropped(carrier)
	else
		self:Dropped()
	end
end

function ENT:PhysicsCollide(data, phys)
	if 50 < data.Speed and 0.3 < data.DeltaTime then
		self:EmitSound("npc/turret_floor/click1.wav")
	end
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end
