AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then phys:EnableMotion(false) end

	self.Powering = false
	self.NextEvaluate = 0
	self.ExtractPower = 20
	self.LastObelisk = NULL
	self.LastSkin = 0
end

function ENT:Think()
	if self.Destroyed then return end
	if self.NextEvaluate <= CurTime() then
		self.NextEvaluate = CurTime() + 2

		local startpos = self:GetPos() + self:GetUp() * 34

		local tr = util.TraceLine({start = startpos, endpos = startpos + self:GetForward() * -48, filter = self})
		local ent = tr.Entity
		local extracting
		if ent:IsValid() and ent:GetClass():lower() == "obelisk" then
			local lastobelisk = self.LastObelisk
			if lastobelisk == ent then
				extracting = true
			else
				if lastobelisk:IsValid() then
					lastobelisk.Sappers = lastobelisk.Sappers - 1
				end
				if ent.Sappers < 1 then
					self.LastObelisk = ent
					ent.Sappers = ent.Sappers + 1
					extracting = true
				else
					self.LastObelisk = NULL
					extracting = false
				end
			end
		end
		
		local myteam = self:GetTeamID()
		local tr = util.TraceLine({start = startpos, endpos = startpos + self:GetForward() * 32000, filter = self})
		local ent = tr.Entity
		if ent:IsValid() and ent.ManaStorage and ent:GetTeamID() == myteam and not ent.Destroyed then
			self.Powering = true
			if extracting and ent.ManaStorage < ent.MaxManaStorage then
				self:EmitSound("weapons/physcannon/energy_sing_flyby1.wav", 70, 70)

				local effectdata = EffectData()
					effectdata:SetOrigin(tr.HitPos)
					effectdata:SetEntity(ent)
					effectdata:SetStart(self:NearestPoint(tr.HitPos))
					effectdata:SetNormal(tr.HitNormal)
					effectdata:SetMagnitude(myteam or 0)
				util.Effect("manatranslocatorrec", effectdata)

				if not ent.ManaReceived or not ent:ManaReceived(self, self.ExtractPower) then
					ent.ManaStorage = math.min(ent.ManaStorage + self.ExtractPower, ent.MaxManaStorage)
				end
			elseif extracting then
				local Current, Total = ent.ManaStorage, ent.MaxManaStorage

				if not ent.ManaReceived or not ent:ManaReceived(self, math.min(self.ExtractPower, (Total - Current))) then
					ent.ManaStorage = ent.ManaStorage + math.min(self.ExtractPower, (Total - Current))
				end
			end
		else
			self.Powering = false
		end

		if extracting and self.LastSkin == 0 then
			self.LastSkin = 1
			self:SetSkin(1)
		elseif not extracting and self.LastSkin == 1 then
			self:SetSkin(0)
			self.LastSkin = 0
		end
	end
end

function ENT:OnRemove()
	local lastobelisk = self.LastObelisk
	if lastobelisk:IsValid() then
		lastobelisk.Sappers = lastobelisk.Sappers - 1
	end
end

function ENT:Info(pl)
	if pl:Team() == self:GetTeamID() then
		return self.PHealth..","..self.MaxPHealth..","..tostring(self.Powering)
	end

	return "deny"
end

ENT.DestructionEffect = PROPGENERICDESTRUCTIONEFFECT
ENT.MoneyBonus = 20
ENT.OffenseBonus = 2
ENT.FragsBonus = 2
ENT.ProcessDamage = PROPGENERICPROCESSDAMAGE
