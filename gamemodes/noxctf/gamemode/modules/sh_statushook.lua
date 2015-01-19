local meta = FindMetaTable("Player")
if not meta then return end

function meta:WeaponHook(hookname, ...)
	local wep = self:GetActiveWeapon()
	if wep:IsValid() and wep[hookname] then
		return wep[hookname](wep, ...)
	end
end

function meta:StatusHook(hookname, ...)
	for _, ent in pairs(ents.FindByClass("status_*")) do
		if ent:GetOwner() == self and ent[hookname] then
			local ret = ent[hookname](ent, ...)
			if ret ~= nil then return ret end
		end
	end
end

function meta:StatusWeaponHook(hookname, ...)
	local ret = self:WeaponHook(hookname, ...)
	if ret ~= nil then return ret end
	return self:StatusHook(hookname, ...)
end

function meta:GlobalHook(hookname, ...)
	local ret = self:StatusWeaponHook(hookname, ...)
	if ret ~= nil then return ret end
	return gamemode.Call(hookname, self, ...)
end
