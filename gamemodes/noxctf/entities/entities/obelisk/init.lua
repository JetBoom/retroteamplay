AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local rockmodels = {"models/props_wasteland/rockcliff01b.mdl",
"models/props_wasteland/rockcliff01c.mdl",
"models/props_wasteland/rockcliff01e.mdl",
"models/props_wasteland/rockcliff01g.mdl"}

ENT.NextSound = 0
ENT.Sappers = 0

function ENT:Initialize()
	self:SetModel(rockmodels[math.random(1, #rockmodels)])
	self:SetPos(self:GetPos() + Vector(0, 0, 8))
	self:PhysicsInitBox(Vector(-14, -14, -48), Vector(14, 14, 48))
	self:SetCollisionBounds(Vector(-14, -14, -48), Vector(14, 14, 48))

	self:SetUseType( CONTINUOUS_USE )
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetMaterial("metal")
		phys:EnableMotion(false)
		phys:Sleep()
	end

	if self:GetMaxMana() == 0 then
		self:SetMaxMana(self.MaxMana)
	end
	self:SetMana(self:GetMaxMana())
end

-- May not be needed
function ENT:Team()
	return 0
end

function ENT:UniqueID()
	return self:EntIndex()
end

function ENT:Alive()
	return self:GetMana() > 0
end
---

function ENT:Use( ent, caller )
	if not self:CanDrain(ent) then return end

	if drain then
		local amount = math.min(self:GetMana(), FrameTime() * self.LeechPerSecond)
		amount = ent:GetStatus("manasickness") and ( amount * 0.3333 ) or amount
		ent:SetMana(math.min(ent:GetMana() + amount, ent:GetMaxMana()), true)
		self:SetMana(self:GetMana() - amount)
	elseif ent:IsPlayer() and 1 <= self:GetMana() and 0 < ent:GetManaRegeneration() then
		local wep = ent:GetActiveWeapon()
		if wep:IsValid() and wep.MaxMana and ent:GetAmmoCount(wep.ChargeAmmo) < wep.MaxMana then
			local amount = math.min(self:GetMana(), FrameTime() * self.DrainPerSecond)
			amount = ent:GetStatus("manasickness") and ( amount * 0.3333 ) or amount
			ent:SetMana(math.min(ent:GetMana() + amount, ent:GetMaxMana()), true)
			ent:GiveAmmo(1, wep.ChargeAmmo)
			self:SetMana(self:GetMana() - amount)

			self:PlayDrainSound()
		elseif ent:GetMana() < ent:GetMaxMana() then
			local amount = math.min(self:GetMana(), FrameTime() * self.DrainPerSecond)
			amount = ent:GetStatus("manasickness") and ( amount * 0.3333 ) or amount
			ent:SetMana(math.min(ent:GetMana() + amount, ent:GetMaxMana()), true)
			self:SetMana(self:GetMana() - amount)

			self:PlayDrainSound()
		end
	end
	
end

function ENT:Touch(ent, drain)
	if not self:CanDrain(ent) then return end

	if drain then
		local amount = math.min(self:GetMana(), FrameTime() * self.LeechPerSecond)
		amount = ent:GetStatus("manasickness") and ( amount * 0.3333 ) or amount
		ent:SetMana(math.min(ent:GetMana() + amount, ent:GetMaxMana()), true)
		self:SetMana(self:GetMana() - amount)
	elseif ent:IsPlayer() and 1 <= self:GetMana() and 0 < ent:GetManaRegeneration() then
		local wep = ent:GetActiveWeapon()
		if wep:IsValid() and wep.MaxMana and ent:GetAmmoCount(wep.ChargeAmmo) < wep.MaxMana then
			local amount = math.min(self:GetMana(), FrameTime() * self.DrainPerSecond)
			amount = ent:GetStatus("manasickness") and ( amount * 0.3333 ) or amount
			ent:SetMana(math.min(ent:GetMana() + amount, ent:GetMaxMana()), true)
			ent:GiveAmmo(1, wep.ChargeAmmo)
			self:SetMana(self:GetMana() - amount)

			self:PlayDrainSound()
		elseif ent:GetMana() < ent:GetMaxMana() then
			local amount = math.min(self:GetMana(), FrameTime() * self.DrainPerSecond)
			amount = ent:GetStatus("manasickness") and ( amount * 0.3333 ) or amount
			ent:SetMana(math.min(ent:GetMana() + amount, ent:GetMaxMana()), true)
			self:SetMana(self:GetMana() - amount)

			self:PlayDrainSound()
		end
	end
end

function ENT:CanDrain(ent)
	return self:GetMana() > self.NoDrainThreshold
end

function ENT:PlayDrainSound()
	if CurTime() >= self.NextSound then
		self.NextSound = CurTime() + 0.75
		self:EmitSound("nox/managain.ogg")
	end
end
