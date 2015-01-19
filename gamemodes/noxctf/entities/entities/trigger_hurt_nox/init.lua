ENT.Type = "brush"

function ENT:Initialize()
	self.onplayerhurts = self.onplayerhurts or {}
	self.onplayerkilleds = self.onplayerkilleds or {}
	self.onnpchurts = self.onnpchurts or {}
	self.onnpckilleds = self.onnpckilleds or {}
	self.onvehiclehurts = self.onvehiclehurts or {}
	self.onvehiclekilleds = self.onvehiclekilleds or {}
	self.onbuildinghurts = self.onbuildinghurts or {}
	self.onbuildingkilleds = self.onbuildingkilleds or {}

	self.Damage = self.Damage or 10
	self.DamageType = self.DamageType or DMGTYPE_GENERIC
	if self.On == nil then
		self.On = true
	end
	self.DamageRecycle = self.DamageRecycle or 0.5
	if self.DamagePlayers == nil then
		self.DamagePlayers = true
	end
	if self.DamageNPCs == nil then
		self.DamageNPCs = true
	end
	if self.DamageVehicles == nil then
		self.DamageVehicles = true
	end
end

function ENT:Think()
end

function ENT:StartTouch(ent)
end

function ENT:EndTouch(ent)
end

function ENT:AcceptInput(name, caller, activator, arg)
	name = string.lower(name)
	if name == "seton" then
		self.On = tonumber(arg) == 1
		return true
	elseif name == "enable" then
		self.On = true
		return true
	elseif name == "disable" then
		self.On = false
		return true
	end
end

function ENT:KeyValue(key, value)
	key = string.lower(key)
	if key == "damage" then
		self.Damage = tonumber(value) or 0
	elseif key == "starton" then
		self.On = tonumber(value) == 1
	elseif key == "damagerecycle" then
		self.DamageRecycle = tonumber(value) or self.DamageRecycle or 0.5
	elseif key == "damagetype" then
		value = string.lower(value)
		if value == "fire" then
			self.DamageType = DMGTYPE_FIRE
		elseif value == "ice" then
			self.DamageType = DMGTYPE_ICE
		elseif value == "poison" then
			self.DamageType = DMGTYPE_POISON
		elseif value == "infectiouspoison" then
			self.DamageType = DMGTYPE_POISON
		elseif value == "generic" then
			self.DamageType = DMGTYPE_GENERIC
		elseif value == "physical" then
			self.DamageType = DMGTYPE_IMPACT
		elseif value == "electric" then
			self.DamageType = DMGTYPE_ELECTRIC
		end
		self.Infect = value == "infectiouspoison"
		self.DamageRecycle = tonumber(value) or self.DamageRecycle or 0.5
	elseif key == "damagefilter" then
		value = tonumber(value) or 0
		self.DamagePlayers = 2 and value == 2
		self.DamageNPCs = 4 and value == 4
		self.DamageVehicles = 8 and value == 8
		self.DamageBuildings = 16 and value == 16
	elseif key == "onplayerhurt" then
		local tab = string.Explode(",", value)
		self.onplayerhurts = self.onplayerhurts or {}
		table.insert(self.onplayerhurts, {entityname=tab[1], input=tab[2], args=tab[3], delay=tab[4], reps=tab[5]})
	elseif key == "onplayerkilled" then
		local tab = string.Explode(",", value)
		self.onplayerkilleds = self.onplayerkilleds or {}
		table.insert(self.onplayerkilleds, {entityname=tab[1], input=tab[2], args=tab[3], delay=tab[4], reps=tab[5]})
	elseif key == "onnpchurt" then
		local tab = string.Explode(",", value)
		self.onnpchurts = self.onnpchurts or {}
		table.insert(self.onnpchurts, {entityname=tab[1], input=tab[2], args=tab[3], delay=tab[4], reps=tab[5]})
	elseif key == "onnpckilled" then
		local tab = string.Explode(",", value)
		self.onnpckilleds = self.onnpckilleds or {}
		table.insert(self.onnpckilleds, {entityname=tab[1], input=tab[2], args=tab[3], delay=tab[4], reps=tab[5]})
	elseif key == "onvehiclehurt" then
		local tab = string.Explode(",", value)
		self.onvehiclehurts = self.onvehiclehurts or {}
		table.insert(self.onvehiclehurts, {entityname=tab[1], input=tab[2], args=tab[3], delay=tab[4], reps=tab[5]})
	elseif key == "onvehiclekilled" then
		local tab = string.Explode(",", value)
		self.onvehiclekilleds = self.onvehiclekilleds or {}
		table.insert(self.onvehiclekilleds, {entityname=tab[1], input=tab[2], args=tab[3], delay=tab[4], reps=tab[5]})
	end
end

function ENT:Touch(ent)
	if self.On and (not ent.NextTriggerNoXHurt or ent.NextTriggerNoXHurt < CurTime()) and 0 < self.Damage then
		local pass = false
		if ent.SendLua and ent:Alive() and self.DamagePlayers then pass = true
		elseif ent.ScriptVehicle and self.DamageVehicles then pass = true
		elseif ent:IsNPC() and self.DamageNPCs then pass = true
		elseif ent.PHealth and self.DamageBuildings then pass = true end
		if not pass then return end

		ent.NextTriggerNoXHurt = CurTime() + self.DamageRecycle
		if self.Infect and ent:IsPlayer() then ent:Poison() end

		if ent.TakeSpecialDamage then
			ent:TakeSpecialDamage(self.Damage, self.DamageType, self, self)
		else
			ent:TakeDamage(self.Damage, self, self)
		end

		if ent.SendLua then
			self:FireOff(self.onplayerhurts, ent, self)
			if ent:Health() <= 0 then
				self:FireOff(self.onplayerkilleds, ent, self)
			end
		elseif ent:IsNPC() then
			self:FireOff(self.onnpchurts, ent, self)
			if ent:Health() <= 0 then
				self:FireOff(self.onnpckilleds, ent, self)
			end
		elseif ent.ScriptVehicle then
			self:FireOff(self.onvehiclehurts, ent, self)
			if ent:GetVHealth() <= 0 then
				self:FireOff(self.onvehiclekilleds, ent, self)
			end
		elseif ent.PHealth then
			self:FireOff(self.onbuildinghurts, ent, self)
		end
	end
end

function ENT:FireOff(intab, activator, caller)
	for key, tab in pairs(intab) do
		for __, subent in pairs(ents.FindByName(tab.entityname)) do
			if tab.delay == 0 then
				subent:Input(tab.input, activator, caller, tab.args)
			else
				timer.Simple(tab.delay, function() if subent:IsValid() then subent:Input(tab.input, activator, caller, tab.args) end end)
			end
		end
	end
end
