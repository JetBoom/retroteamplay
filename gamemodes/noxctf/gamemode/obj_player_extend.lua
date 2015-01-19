local meta = FindMetaTable("Player")
if not meta then return end

function meta:IsInvisible()
	return self:GetVisibility() <= 0.4
end

function meta:IsVisibleTarget(watcher) -- DEPRECATED
	return not self:IsInvisible()
end

function meta:GetVisibility()
	local status = self:GetStatus("invisibility") or self:GetStatus("shadowstorm")
	if status and status:IsValid() then
		if CLIENT then
			return status:GetVisibility(self)
		end

		return 0
	end

	return 1
end

if CLIENT then
	function meta:CustomGesture(gesture)
		--self:DoAnimationEvent(gesture)
		self:AnimRestartGesture(GESTURE_SLOT_CUSTOM, gesture, true)
	end
	usermessage.Hook("cusges", function(um)
		local ent = um:ReadEntity()
		local gesture = um:ReadShort()
		if ent:IsValid() then
			ent:CustomGesture(gesture)
		end
	end)

	function meta:FixModelAngles(velocity)
		local eye = self:EyeAngles()
		self:SetLocalAngles(eye)
		self:SetRenderAngles(eye)
		self:SetPoseParameter("move_yaw", math.NormalizeAngle(velocity:Angle().yaw - eye.y))
	end

	function meta:CenterPrint(message, color, lifetime)
		GAMEMODE:CenterPrint(message, color, lifetime)
	end
end

function meta:StopIfOnGround()
	if self:OnGround() then
		self:SetLocalVelocity(Vector(0, 0, 0))
	end
end

function meta:TraceHull(distance, mask, radius)
	local vradius = Vector(radius, radius, radius)
	local start = self:EyePos()
	local filter = ents.FindByClass("projectile_*")
	filter[#filter + 1] = self
	return util.TraceHull({start = start, endpos = start + self:GetAimVector() * distance, filter = filter, mask = mask, mins = vradius * -1, maxs = vradius})
end

function meta:CallClassFunction(funcname, ...)
	local tab = self:GetClassTable()
	if tab[funcname] then
		return tab[funcname](tab, self, ...)
	end
end

function meta:SetPlayerClass(classid)
	self:SetDTInt(3, classid)
end

function meta:GetPlayerClass()
	return self:GetDTInt(3)
end

function meta:GetPlayerClassTable()
	return CLASSES[self:GetPlayerClass()]
end
meta.GetClassTable = meta.GetPlayerClassTable

function meta:CanTakeFlag(flag)
	local ret = self:StatusWeaponHook("CanTakeFlag", flag)
	if ret == false then return false end

	return self:Alive() and not self:InVehicle() and CurTime() >= self.LastDeath + 1 and CurTime() >= (self.NextFlagPickup or 0)
end

function meta:GetTeamName()
	return team.GetName(self:Team()) or "None"
end

function meta:GetAttackFilter()
	return team.GetPlayers(self:GetTeamID())
end

function meta:IsFacing(ent)
	local pos = ent:GetPos()
	local shootpos = self:GetShootPos()

	return pos:Distance(shootpos + self:GetAimVector() * 8) < pos:Distance(shootpos)
end

function meta:IsPointingAt(ent)
	return self:GetEyeTrace().Entity == ent
end

function meta:TraceLine(distance, _mask)
	local vStart = self:GetShootPos()
	local filt = ents.FindByClass("projectile_*")
	table.insert(filt, self)
	return util.TraceLine({start = vStart, endpos = vStart + self:GetAimVector() * distance, filter = filt, mask = _mask})
end

function meta:ConvertNet()
	return ConvertNet(self:SteamID())
end

function meta:AddFrozenPhysicsObject(ent, phys)
end

function meta:UnfreezePhysicsObjects(ent, phys)
	return 0
end

function meta:GetMana()
	return math.min(self:GetMaxMana(), self.Mana + self:GetManaRegeneration() * (CurTime() - self.ManaBase))
end

function meta:GetMaxMana()
	return self:GetClassTable().Mana
end

function meta:GetManaRegeneration()
	return self:GetClassTable().ManaRegeneration
end

function meta:SetMana(mana, send)
	local ct = CurTime()

	self.Mana = math.Clamp(mana, 0, self:GetMaxMana())
	self.ManaBase = ct

	if send and SERVER then
		umsg.Start("SLM", self)
			umsg.Float(mana)
			umsg.Float(ct)
		umsg.End()
	end
end

meta.GetTeamID = meta.Team

if CLIENT then
	function meta:GetMaxHealth()
		return self:GetPlayerClassTable().Health
	end

	function meta:DI(spellid, tTime)
		if tTime == 0 then
			DelayIcons[spellid] = nil
		elseif tTime > 0 then
			local curtime = CurTime()
			DelayIcons[spellid] = {StartTime = curtime, EndTime = curtime + tTime}
		else
			DelayIcons[spellid] = {StartTime = CurTime(), EndTime = -10}
		end
	end

	function meta:GetStatus(sType)
		for _, ent in pairs(ents.FindByClass("status_"..sType)) do
			if ent:GetOwner() == self then return ent end
		end
	end
end

function meta:GetCastableSpells()
	return self:GetPlayerClassTable().CastableSpells
end

function meta:NumCastableSpells()
	if not self:GetCastableSpells() then return NULL end
	return #self:GetCastableSpells()
end

function meta:CanTeleport()
	local ret = self:StatusWeaponHook("CanTeleport")
	if ret ~= nil then return ret end

	return true
end

function meta:IsAnchored()
	return self:GetStatus("anchor")
end

local oldalive = meta.Alive
function meta:Alive()
	return self:GetMoveType() ~= MOVETYPE_OBSERVER and self:Team() ~= TEAM_SPECTATOR and oldalive(self)
end

-- Override these because they're different in 1st person and on the server.
function meta:SyncAngles()
	local ang = self:EyeAngles()
	ang.pitch = 0
	ang.roll = 0
	return ang
end
meta.GetAngles = meta.SyncAngles

function meta:GetForward()
	return self:SyncAngles():Forward()
end

function meta:GetUp()
	return self:SyncAngles():Up()
end

function meta:GetRight()
	return self:SyncAngles():Right()
end

function meta:TraceSphere(distance, radius)
	local start = self:EyePos()
	local filter = ents.FindByClass("projectile_*")
	filter[#filter + 1] = self
	local trace = util.TraceLine({start = start, endpos = start + self:GetAimVector() * distance, filter = filter})
	local players = {}
	
	for _, v in pairs(ents.GetAll()) do 
		if v:GetPos():Distance(trace.HitPos) < radius then
			table.insert(players, v)
		end
	end

	return players
end

function meta:GetTraceFilter()
	return team.GetPlayers(self:GetTeamID())
end

function meta:GetMeleeTargets(range, size, addfilter)
	local traces = {}

	local filter = self:GetTraceFilter()
	if addfilter then
		table.Add(filter, addfilter)
	end

	local start = self:GetShootPos()
	local trace = {start = start, endpos = start + self:GetAimVector() * range, mins = Vector(size, size, size) * -1, maxs = Vector(size, size, size), filter = filter, mask = MASK_SOLID}

	for i=1, 50 do
		local tr = util.TraceHull(trace)
		local ent = tr.Entity
		if ent:IsValid() then
			if ent:IsBuilding() then
				table.insert(traces, tr)
				break
			elseif not ent:IsProjectile() then -- We don't care about these entities.
				table.insert(traces, tr)
				table.insert(trace.filter, ent)
			end
		elseif ent:IsWorld() then
			table.insert(traces, tr) -- We hit the world. No more targets.
			break
		end
	end

	for i=1, 50 do
		local tr = util.TraceLine(trace)
		local ent = tr.Entity
		if ent:IsValid() then
			if ent:IsBuilding() then
				table.insert(traces, tr)
				break
			elseif not ent:IsProjectile() then
				table.insert(traces, tr)
				table.insert(trace.filter, ent)
			end
		elseif ent:IsWorld() then
			table.insert(traces, tr)
			break
		end
	end

	if DEBUG and SERVER then debugoverlay.Box(start + self:GetAimVector() * range, Vector(size, size, size), Vector(size, size, size), 1, COLOR_YELLOW) end
	
	return traces
end

function meta:GetMeleeTargets2(range, size, addfilter)
	local targets = {}

	local filter = self:GetTraceFilter()
	if addfilter then table.Add(filter, addfilter) end

	local start = self:GetShootPos()
	local pos = start + self:GetAimVector() * range
	for _, ent in pairs(ents.FindInSphere(pos, size)) do
		if ent:IsValid() and not table.HasValue(filter, ent) and ((ent:IsPlayer() and ent:Alive()) or (ent.PHealth or ent.ScriptVehicle or ent.VehicleParent or ent.CoreHealth or ent:GetClass() == "netherbomb")) and TrueVisible(start, ent:NearestPoint(start)) then
			targets[ent] = ent:NearestPoint(start)
		end
	end

	if DEBUG and SERVER then debugoverlay.Sphere(pos, size, 2, COLOR_RED) end

	local tr = util.TraceLine({start = start, endpos = pos, mask = MASK_SOLID_BRUSHONLY})

	if tr.HitWorld then
		return targets, tr
	else
		return targets, false
	end
end