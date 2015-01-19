AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
	self:DrawShadow(false)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	self.FullChargeTime = CurTime() + self.ChargeTime
	self.Delta = 0
	self:SetModelScale(0, 0)
end

function ENT:Think()
	local owner = self:GetOwner()
	if not owner:IsValid() or CLASSES[owner:GetPlayerClass()].Name ~= "Assassin" or owner:GetTeamID() ~= self:GetTeamID() or not owner:Alive() then self:Remove() end

	if not self.Delta or self.Delta <= 1 then
		self.Delta = 1 - (self.FullChargeTime - CurTime())/self.ChargeTime
	end

	if not self.NextDrain or CurTime() >= self.NextDrain then
		self.NextDrain = CurTime() + self.DrainInterval
		local attach = self:GetAttach()
		if attach:IsValid() then
			local class = attach:GetClass()
			if attach:GetTeamID() ~= self:GetTeamID() then
				if class == "prop_manacapacitor" or class == "grandcapacitor" or class == "prop_magusshield" or class == "prop_vehiclepad" then
					attach.ManaStorage = math.max(0, attach.ManaStorage - self.DrainAmount)
				elseif class == "obelisk" then
					attach:SetMana(math.max(0, attach:GetMana() - self.ObeliskDrainAmount))
				end
			end
		end
	end

	self:NextThink(CurTime())
	return true
end

function ENT:ProcessDamage(attacker, inflictor, dmginfo)
	if self:GetTeamID() ~= attacker:GetTeamID() then
		self:SetSkin(1)
		self:Remove()
	end
end

function ENT:Detonate()
	local owner = self:GetOwner()
	local pos = self:GetPos()
	local attach = self:GetAttach()
	local delta = self.Delta

	local effectdata = EffectData()
		effectdata:SetOrigin(pos)
		effectdata:SetNormal(self:GetNormal() * -1)
		effectdata:SetMagnitude(delta)
	util.Effect("netherbombexplosion", effectdata)

	local rad = self.MaxRadius * delta
	util.ScreenShake(pos, 15, 5, 0.75, rad)
	for _, ent in pairs(ents.FindInSphere(pos, rad)) do
		if ent:IsValid() and ent ~= self and (ent:GetTeamID() ~= owner:GetTeamID() or ent == owner) and TrueVisible(pos, ent:NearestPoint(pos)) then
			local distdelt = 1 - ent:NearestPoint(pos):Distance(pos)/rad
			local dmg = ((ent == attach and self.MaxDamage * self.AttachMultiplier) or self.MaxDamage) * delta * distdelt
			ent:TakeSpecialDamage(dmg, self.DamageType, owner, self)

			if ent:IsPlayer() and ent:Alive() and ent:GetManaRegeneration() ~= 0 then
				ent:GiveStatus(self.Debuff, self.MaxDebuffDuration * delta)
			end
		end
	end

	self:Remove()
end