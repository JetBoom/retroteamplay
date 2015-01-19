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
	self.Phys = self:GetPhysicsObject()
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetTrigger(true)
	if self.Phys:IsValid() then
		self.Phys:SetMass(500)
		self.Phys:EnableMotion(true)
		self.Phys:Wake()
	end

	self.AutoReturnTimer = 45

	self.LastThink = 0
	
	self:SetImmunity(90)
end

function ENT:Dropped(pl)
	pl = pl or NULL
	local byplayer = "itself"
	if pl:IsValid() then
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
	self.AutoReturnTimer = CurTime() + 45
	self:SetSkin(0)

	if pl:IsValid() then
		gamemode.Call("HTF_FlagDropped", pl)
	end
end

function ENT:Touch(hitent)
	if ENDGAME then return end

	if CurTime() < self:GetImmunity() and hitent:IsPlayer() then
		if self.NextCantTakeMsg < CurTime() then
			hitent:CenterPrint("The flag is currently immune to pickups!", "COLOR_RED")
			self.NextCantTakeMsg = CurTime() + 1
		end
	elseif hitent:IsPlayer() and hitent:CanTakeFlag(self) and not self:GetCarrier():IsValid() and not hitent:InVehicle() and hitent.LastDeath + 1 <= CurTime() and CurTime() >= (hitent.NextFlagPickup or 0) then
		if 1 < #player.GetAll() then
			if self.LastDrop + 0.75 <= CurTime() then
				self:SetSolid(SOLID_NONE)
				self:SetCarrier(hitent)
				self.Phys:EnableGravity(false)
				self.Phys:EnableMotion(true)
				self.Phys:Wake()
				hitent.Carrying = self
				self:SetSkin(hitent:Team())
				GAMEMODE:HTF_FlagTaken(hitent)
				self.AutoReturnTimer = CurTime() + 45
				self:SetOwner(hitent)
				hitent:RemoveInvisibility()
			end
		elseif self.NextCantTakeMsg < CurTime() then
			hitent:PrintMessage(4, "You can't take the flag while there are no others in the server!")
			self.NextCantTakeMsg = CurTime() + 1
		end
	end
end

function ENT:Reset(dontannounce)
	self.AutoReturnTimer = CurTime() + 45

	local flagpoint = GAMEMODE.BallDrop
	 
	if self:GetOwner():IsValid() then
		self:GetOwner().Carrying = nil
	end

	umsg.Start("FlagReturnEffect")
		umsg.Vector(self:GetPos())
		umsg.Vector(flagpoint)
		umsg.Short(TEAM_SPECTATOR)
	umsg.End()

	self:SetSolid(SOLID_VPHYSICS)
	self:SetPos(flagpoint)
	self:SetCarrier(NULL)
	self.Phys:EnableGravity(true)
	self.Phys:EnableMotion(true)
	self.Phys:Wake()
	self.Phys:SetVelocityInstantaneous(Vector(0, 0, 0))
	self:SetSkin(0)
	self.LastDrop = CurTime()
	self.AutoReturnTimer = CurTime() + 30

	if not dontannounce then
		GAMEMODE:HTF_FlagReset()
	end
end

function ENT:Think()
	local ct = CurTime()
	local ft = ct - (self.LastThink or 0)
	self.LastThink = ct

	if self.AutoReturnTimer and self.AutoReturnTimer <= CurTime() then
		self:Reset()
		return
	end

	local carrier = self:GetCarrier()
	if carrier:IsValid() then
		if carrier:Alive() then
			self:AlignToCarrier()
			GAMEMODE:HTF_AwardPoints(carrier, carrier:Team(), ft, self)
			self.Phys:SetVelocityInstantaneous(Vector(0, 0, 0))
		elseif carrier:IsValid() then
			self:Dropped(carrier)
		else
			self:Dropped()
		end
	end
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

function ENT:PhysicsCollide(data, phys)
	if 50 < data.Speed and 0.3 < data.DeltaTime then
		self:EmitSound("npc/turret_floor/click1.wav")
	end
end

local oldskin = ENT.SetSkin
function ENT:SetSkin(iSkin)
	if iSkin == 0 then
		self:SetColor(Color(255, 255, 255, 255))
	else
		local col = team.GetColor(iSkin)
		self:SetColor(Color(col.r, col.g, col.b, 255))
	end

	oldskin(self, iSkin)
end
