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

	self:Fire("evaluate", "", 0.1)

	self.Mana = 0
	self.MaxMana = 50
	--self.LastDrain = -10
	self.NextSound = -10
	self.LastBrightness = 255

	self.LstThnk = CurTime()

	self:SetNetworkedInt("brit", 255)
end

function ENT:AcceptInput(name, activator, caller)
	if name == "evaluate" then
		self:Fire("evaluate", "", 3)

		GAMEMODE:Evaluate(self, true)

		return true
	elseif name == "depowered" then
		self:SetSkin(0)

		return true
	elseif name == "powered" then
		self:SetSkin(1)

		return true
	end
end

function ENT:Think()
	if self.Destroyed then return end
	local ct = CurTime()
	if self.Mana < self.MaxMana and GAMEMODE:DrainPower(self, 3) then-- and self.LastDrain + 1 < ct then
		local ft = ct - self.LstThnk
		self.LstThnk = ct
		self.Mana = math.min(self.MaxMana, self.Mana + 5)
		local brightness = math.ceil(math.max(self.Mana * 5.1, 30))
		if self.LastBrightness ~= math.ceil(brightness * 0.1) then
			self.LastBrightness = brightness
			self:SetNetworkedInt("brit", brightness)
		end
	end

	self:NextThink(ct + 0.5)
	return true
end

function ENT:Touch(ent, drain)
	if self.Destroyed then return end

	if drain then
		local amount = math.ceil(math.min(self.Mana, FrameTime() * 120))
		ent:SetMana(math.min(ent:GetMana() + amount, ent:GetMaxMana()), true)
		self.Mana = self.Mana - amount
		local brightness = math.ceil(math.max((self.Mana / self.MaxMana) * 255, 30))

		if self.LastBrightness ~= math.ceil(brightness * 0.1) then
			self:SetColor(Color(0, brightness * 0.5, brightness, 255))
			self.LastBrightness = brightness
		end

		self.LstThnk = CurTime()
	elseif ent:IsPlayer() and 1 <= self.Mana and 0 < ent:GetManaRegeneration() then
		local wep = ent:GetActiveWeapon()
		if wep:IsValid() and wep.MaxMana and ent:GetAmmoCount(wep.ChargeAmmo) < wep.MaxMana then
			local amount = math.ceil(math.min(self.Mana, FrameTime() * 66))
			ent:SetMana(math.min(ent:GetMana() + amount, ent:GetMaxMana()), true)
			ent:GiveAmmo(1, wep.ChargeAmmo)
			self.Mana = self.Mana - amount
			local brightness = math.ceil(math.max((self.Mana / self.MaxMana) * 255, 30))
			if self.LastBrightness ~= math.ceil(brightness*0.1) then
				self.LastBrightness = brightness
				self:SetNetworkedInt("brit", brightness)
			end

			self.LstThnk = CurTime()
			if CurTime() >= self.NextSound then
				self:EmitSound("nox/managain.ogg")
				self.NextSound = CurTime() + 0.75
			end
		elseif ent:GetMana() < ent:GetMaxMana() then
			local amount = math.ceil(math.min(self.Mana, FrameTime() * 66), true)
			ent:SetMana(math.min(ent:GetMana() + amount, ent:GetMaxMana()))
			self.Mana = self.Mana - amount
			local brightness = math.ceil(math.max((self.Mana / self.MaxMana) * 255, 30))
			if self.LastBrightness ~= math.ceil(brightness*0.1) then
				self.LastBrightness = brightness
				self:SetNetworkedInt("brit", brightness)
			end

			self.LstThnk = CurTime()
			if CurTime() >= self.NextSound then
				self:EmitSound("nox/managain.ogg")
				self.NextSound = CurTime() + 0.75
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
ENT.MoneyBonus = 10
ENT.OffenseBonus = 1
ENT.FragsBonus = 1
ENT.ProcessDamage = PROPGENERICPROCESSDAMAGE
