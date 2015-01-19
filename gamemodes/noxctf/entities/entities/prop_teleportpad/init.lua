-- TODO: Glitch protection (people can go outside the map).

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetTrigger(true)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then phys:EnableMotion(false) end

	self.NextTeleport = 0
	self.Think = nil
end

function ENT:StartTouch(ent)
end

function ENT:Touch(ent)
	if self.Destroyed then return end
	if ent:IsPlayer() and CurTime() >= self.NextTeleport and self.Connection and self.Connection:IsValid() and ent:GetPos():Distance(self:GetPos()) < 32 then
		if ent:IsCarrying() then ent:LM(30) return end
		local connectionpos = self.Connection:GetPos()
		local connectionup = self.Connection:GetUp()
		local tr = util.TraceLine({start = connectionpos, endpos = connectionpos + connectionup * 80})
		if not tr.Hit then
			--if GAMEMODE:DrainPower(self, 10) then
				self.Connection.NextTeleport = CurTime() + 2
				self.NextTeleport = CurTime() + 2
				ent:SetPos(connectionpos + connectionup * 72)
				local effectdata = EffectData()
					effectdata:SetOrigin(self:GetPos() + self:GetUp() * 4)
				timer.Simple(0, function() util.Effect("TeleportSparks", effectdata) end)
			--else
				--self.Connection.NextTeleport = CurTime() + 0.5
				--self.NextTeleport = CurTime() + 0.5
				--if ent.SendLua then
--					ent:SendLua("LMR(58)")
				--end
			--end
		end
	end
end

function ENT:EndTouch(ent)
end

function ENT:Use(activator, caller)
	if self.Destroyed then return end
	if not activator:IsPlayer() then return end

	if activator:Team() == self:GetTeamID() then
		if not (self.Connection and self.Connection:IsValid()) then
			if activator.TeleportConnecting and activator.TeleportConnecting == self then
				activator:PrintMessage(4, "You decide not to connect it to anything.")
				activator:SendLua([[surface.PlaySound("buttons/button16.wav")]])
				activator.TeleportConnecting = nil
			elseif activator.TeleportConnecting and activator.TeleportConnecting:IsValid() then
				self.Connection = activator.TeleportConnecting
				activator.TeleportConnecting.Connection = self
				activator:PrintMessage(4, "You connect the two teleport pads.")
				activator:SendLua([[surface.PlaySound("buttons/button14.wav")]])
				activator.TeleportConnecting = nil
			else
				activator:PrintMessage(4, "Press USE on another teleport pad to permanently connect them.")
				activator:SendLua([[surface.PlaySound("buttons/button9.wav")]])
				activator.TeleportConnecting = self
			end
		end
	end
end

function ENT:Info(pl)
	if pl:Team() == self:GetTeamID() then
		return self.PHealth..","..self.MaxPHealth..","..tostring(self.Connection and self.Connection:IsValid() and self.Connection ~= self)
	end

	return "deny"
end

ENT.DestructionEffect = PROPGENERICDESTRUCTIONEFFECT
ENT.MoneyBonus = 20
ENT.OffenseBonus = 2
ENT.FragsBonus = 2
ENT.ProcessDamage = PROPGENERICPROCESSDAMAGE
