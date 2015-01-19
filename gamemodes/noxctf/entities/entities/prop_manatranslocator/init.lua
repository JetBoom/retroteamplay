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

	self.NextShoot = 0
end

function ENT:Think()
	if not self.Destroyed and self.NextShoot <= CurTime() then
		self.NextShoot = CurTime() + 2

		local up = self:GetUp()
		local startpos = self:GetPos()

		local filt = player.GetAll()
		table.insert(filt, self)

		local myteam = self:GetTeamID()
		local ent = util.TraceLine({start = startpos, endpos = startpos + up * -40, filter = filt}).Entity

		if ent:IsValid() and ent.ManaStorage and 25 <= ent.ManaStorage and not ent.Destroyed and not ent.NoTranslocate then
			local tr = util.TraceLine({start = startpos + up * 24, endpos = startpos + up * 64000, filter = filt})
			local ent2 = tr.Entity
			if ent2:IsValid() and ent2.ManaStorage and ent2.ManaStorage < ent2.MaxManaStorage and ent2:GetTeamID() == myteam and not ent2.Destroyed then
				ent.ManaStorage = ent.ManaStorage - 25
				ent:SetSkin(ent.ManaStorage)
				self:EmitSound("weapons/physcannon/energy_sing_flyby1.wav", 70, 70)

				local effectdata = EffectData()
					effectdata:SetOrigin(tr.HitPos)
					effectdata:SetEntity(ent2)
					effectdata:SetStart(self:NearestPoint(tr.HitPos))
					effectdata:SetNormal(tr.HitNormal)
					effectdata:SetMagnitude(myteam or 0)
				util.Effect("manatranslocatorrec", effectdata)

				if not ent2.ManaReceived or not ent2:ManaReceived(self, 25) then
					ent2.ManaStorage = math.min(ent2.MaxManaStorage, ent2.ManaStorage + 25)
				end
			end
		end
	end
end

function ENT:Info(pl)
	if pl:Team() == self:GetTeamID() then
		return self.PHealth..","..self.MaxPHealth
	end

	return "deny"
end

ENT.DestructionEffect = PROPGENERICDESTRUCTIONEFFECT
ENT.MoneyBonus = 30
ENT.OffenseBonus = 3
ENT.FragsBonus = 3
ENT.ProcessDamage = PROPGENERICPROCESSDAMAGE
