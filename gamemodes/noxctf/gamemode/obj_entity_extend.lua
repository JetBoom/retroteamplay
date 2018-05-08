local meta = FindMetaTable("Entity")
if not meta then return end

function IsIndoors(pos, allowance)
	local tr = util.TraceLine({start = pos, endpos = pos + Vector(0, 0, allowance and 256 or 20480), mask = MASK_SOLID_BRUSHONLY})
	return tr.Hit and not tr.HitSky
end

function meta:IsIndoors(allowance)
	return IsIndoors(self:EyePos(), allowance)
end

function meta:GetColorOld()
	local col = self:GetColor()
	return col.r, col.g, col.b, col.a
end

function meta:IsBuilding()
	return self.m_IsBuilding
end

function meta:IsProjectile()
	return self.m_IsProjectile
end

function meta:GetCenter()
	return self:GetPos() + Vector(0, 0, self:OBBMaxs().z * 0.5)
end

function meta:SetAlpha(a)
	self:SetRenderMode(RENDERMODE_TRANSALPHA)

	local c = self:GetColor()
	self:SetColor(Color(c.r, c.g, c.b, a))
end

function meta:SetAlphaModulation(a)
	self:SetRenderMode(RENDERMODE_TRANSALPHA)

	local c = self:GetColor()
	self:SetColor(Color(c.r, c.g, c.b, a * 255))
end

function meta:IsMDF()
	return self.MDF and CurTime() <= self.MDF
end

function meta:GetAlpha()
	return self:GetColor().a
end

function meta:GetAlphaModulation()
	return self:GetAlpha() / 255
end

function meta:IsOpaque()
	return self:GetAlpha() == 255
end

function meta:CantFireWarning()
	if CurTime() >= (self.CantFireWarningTime or 0) then
		self.CantFireWarningTime = CurTime() + 0.35
		self:EmitSound("Weapon_Shotgun.Empty")
	end
end

function meta:GetVehicleParent()
	return self:GetDTEntity(0)
end

function meta:SetVehicleParent(veh)
	self:SetDTEntity(0, veh)
end

function meta:GetVehicleSlot()
	return self:GetDTInt(0)
end

function meta:SetVehicleSlot(slot)
	self:SetDTInt(0, slot)
end

function meta:SetTeamID(teamid)
	self:SetDTInt(3, teamid) --self.TeamID = teamid
	if self.SetTeam then self:SetTeam(teamid) end
end

function meta:GetTeamID()
	return self.Team and self:Team() or self:GetDTInt(3) --return self.Team and self:Team() or self.TeamID or 0
end

-- I don't know why but using pl:LocalToWorld(pl:OBBCenter()) will fuck up drawing for that frame if parented. It'll appear to be 'attached' to the player's head.
-- Using this method doesn't do it.
function meta:CenterOnPlayer(pl)
	self:SetPos(pl:GetCenter())
end

function meta:TakeSpecialDamage(damage, damagetype, attacker, inflictor, hitpos)
	attacker = attacker or self
	if not IsValid(attacker) then attacker = self end

	inflictor = inflictor or attacker
	if not IsValid(inflictor) then inflictor = attacker end

	local dmginfo = DamageInfo()
	dmginfo:SetDamage(damage)
	dmginfo:SetAttacker(attacker)
	dmginfo:SetInflictor(inflictor)
	dmginfo:SetDamagePosition(hitpos or self:NearestPoint(inflictor:NearestPoint(self:LocalToWorld(self:OBBCenter()))))
	dmginfo:SetDamageType(damagetype)
	local vel = self:GetVelocity()
	self:TakeDamageInfo(dmginfo)
	self:SetLocalVelocity(vel)

	return dmginfo
end

if CLIENT then
	if not meta.TakeDamageInfo then
		meta.TakeDamageInfo = function() end
	end
end

if CLIENT then
	function meta:SetModelScaleVector(vec)
		local bonecount = self:GetBoneCount()
		if bonecount and bonecount > 1 then
			local scale
			if type(vec) == "number" then
				scale = vec
			else
				scale = math.min(vec.x, vec.y, vec.z)
			end
			self._ModelScale = Vector(scale, scale, scale)
			self:SetModelScale(scale, 0)
		else
			if type(vec) == "number" then
				vec = Vector(vec, vec, vec)
			end

			self._ModelScale = vec
			local m = Matrix()
			m:Scale(vec)
			self:EnableMatrix("RenderMultiply", m)
		end
	end

	if not meta.TakeDamageInfo then
		meta.TakeDamageInfo = function() end
	end
	if not meta.SetPhysicsAttacker then
		meta.SetPhysicsAttacker = function() end
	end
end

local meta = FindMetaTable("Weapon")
if not meta then return end

function meta:GetNextPrimaryFire()
	return self.m_NextPrimaryFire or 0
end

function meta:GetNextSecondaryFire()
	return self.m_NextSecondaryFire or 0
end

meta.OldSetNextPrimaryFire = meta.SetNextPrimaryFire
function meta:SetNextPrimaryFire(fTime)
	self.m_NextPrimaryFire = fTime
	self:OldSetNextPrimaryFire(fTime)
end

meta.OldSetNextSecondaryFire = meta.SetNextSecondaryFire
function meta:SetNextSecondaryFire(fTime)
	self.m_NextSecondaryFire = fTime
	self:OldSetNextSecondaryFire(fTime)
end

function meta:SetNextReload(fTime)
	self.m_NextReload = fTime
end

function meta:GetNextReload()
	return self.m_NextReload or 0
end

-- How to use: Define a sound in the shared file of a swep. Sound keys should end with the name Sound. The actual name that you pass to the function is what comes before Sound.
-- For example SWEP.MeleeSwingSound = ... or SWEP.ChargeupSound. "MeleeSwing", "HitFlesh", "Hit", and "HitWorld" are default sound names that are automatically called in the base.
-- You can specify volume, pitch bounds, and several different sounds to play. You can set the value as a table or leave it as just a sound i.e. SWEP.MeleeSwingSound = Sound(...) would just play that sound.
-- The table structure is as follows: SWEP.xSound = {sound = ..., vol = ..., pitchLB = ..., pitchRB = ..., delay = ...} where the sound value can either be a table of sounds or one sound.
function meta:PlaySound(ent, name)
	name = name.."Sound"
	if self[name] then
		if istable(self[name]) then
			local tab = self[name]
			local sound
			if istable(tab.sound) then
				sound = tab.sound[math.random(1, #tab.sound)]
			else
				sound = tab.sound
			end
			if sound then
				local delay = tab.delay
				if tab.vol and tab.pitchLB and tab.pitchRB then
					local vol = tab.vol
					local pitch = math.Rand(tab.pitchLB, tab.pitchRB)

					if delay and delay > 0 then
						timer.Simple(delay, function()
							if ent:IsValid() then ent:EmitSound(sound, vol, pitch) end
						end)
					else
						ent:EmitSound(sound, vol, pitch)
					end
				else
					if delay and delay > 0 then
						timer.Simple(delay, function()
							if ent:IsValid() then ent:EmitSound(sound) end
						end)
					else
						ent:EmitSound(sound)
					end
				end
			end
		else
			ent:EmitSound(self[name])
		end
	end
end

function meta:PlayAnimation(owner, name)
	name = name.."Animation"
	if self[name] then
		if CLIENT then return end

		local tab = self[name]
		local animation
		if istable(tab) then
			animation = tab[math.random(1, #tab)]
		else
			animation = tab
		end

		owner:StopAllLuaAnimations()
		owner:ResetLuaAnimation(animation)
	elseif name == "MeleeSwingAnimation" then
		owner:DoAttackEvent()
	end
end

