AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

SWEP.Classes = {"Spell Saber"}
SWEP.NextVamp = 0
SWEP.VampPool = 0

function SWEP:WeaponThink(owner)
	if self.VampPool > 0 and self.NextVamp < CurTime() then
		GAMEMODE:PlayerHeal(owner, owner, math.min(1,self.VampPool))
		self.VampPool = math.max(0,self.VampPool - 1)
		self.NextVamp = CurTime() + 0.15
	end
end

function SWEP:OnHitPlayer(pl, damage, hitpos)
	local owner = self.Owner
	pl:TakeSpecialDamage(damage, self.MeleeDamageType, owner, self, hitpos)
	if owner:GetStatus("spellsaber_flameblade") then
		if owner:GetMana() >= 15 then
			owner:SetMana(math.max(0, owner:GetMana() - 15), true)
			pl:GiveStatus("flameblade_burn", 2.4).Inflictor = owner
		else
			owner:SendLua("insma()")
		end
	end
	if owner:GetStatus("spellsaber_corruptblade") then
		if owner:GetMana() >= 30 then
			owner:SetMana(math.max(0, owner:GetMana() - 30), true)
			pl:GiveStatus("corruption", 3).Inflictor = owner
		else
			owner:SendLua("insma()")
		end
	end
	if owner:GetStatus("spellsaber_sanguineblade") then
		if owner:GetMana() >= 25 then
			owner:SetMana(math.max(0, owner:GetMana() - 25), true)
			pl:EmitSound("npc/ichthyosaur/snap.wav")
		else
			owner:SendLua("insma()")
		end
	end
	if owner:GetStatus("spellsaber_stormblade") then
		if owner:GetMana() >= 20 then
			pl:GiveStatus("stormblade_arc", 0.6).Inflictor = owner
			owner:SetMana(math.max(0, owner:GetMana() - 20), true)
		else
			owner:SendLua("insma()")
		end
	end
	if owner:GetStatus("spellsaber_shockblade") then
		if owner:GetMana() >= 15 then
			owner:SetMana(math.max(0, owner:GetMana() - 15), true)
			local effectdata = EffectData()
				effectdata:SetOrigin(pl:NearestPoint(hitpos))
				effectdata:SetNormal(Vector(0,0,1))
				SuppressHostEvents(NULL)
			util.Effect("shockwave", effectdata)
			if pl:GetStatus("anchor") then return end
			pl:SetGroundEntity(NULL)
			pl:SetVelocity((owner:GetPos() - pl:GetPos()):GetNormal() * -500 + Vector(0, 0, 140))
		else
			owner:SendLua("insma()")
		end
	end
	if owner:GetStatus("spellsaber_nullblade") then
		if owner:GetMana() >= 20 then
			local manaleech = math.min(12, pl:GetMana())
			if 0 < manaleech then
				local effectdata = EffectData()
					effectdata:SetOrigin(pl:NearestPoint(hitpos))
					effectdata:SetEntity(pl)
					effectdata:SetMagnitude(0)
					SuppressHostEvents(NULL)
				util.Effect("drainmana", effectdata)
				pl:SetMana(pl:GetMana() - manaleech, true)
				owner:SetMana(math.max(0, owner:GetMana() - 20), true)
			end
		else
			owner:SendLua("insma()")
		end
	end
end

function SWEP:OnHitBuilding(ent, damage, hitpos)
	local owner = self.Owner
	ent:TakeSpecialDamage(damage, self.MeleeDamageType, owner, self, hitpos)
	if owner:GetStatus("spellsaber_flameblade") and ent:GetTeamID() ~= owner:GetTeamID() then
		if owner:GetMana() >= 15 then
			owner:SetMana(math.max(0, owner:GetMana() - 15), true)
			ent:TakeSpecialDamage(12, DMGTYPE_FIRE, owner, self)
		else
			owner:SendLua("insma()")
		end
	end
	if owner:GetStatus("spellsaber_stormblade") and ent:GetTeamID() ~= owner:GetTeamID() then
		if owner:GetMana() >= 20 then
			owner:SetMana(math.max(0, owner:GetMana() - 20), true)
			ent:TakeSpecialDamage(10, DMGTYPE_LIGHTNING, owner, self)
		else
			owner:SendLua("insma()")
		end
	end
end

local function CreateIcePath(owner, pos, teamid)
	if not owner:IsValid() or not owner:Alive() or owner:GetMana() < 4 then return end

	local ent = ents.Create("ice_path")

	if ent:IsValid() then
		ent:SetPos(pos)
		if owner:IsValid() then
			ent:SetOwner(owner)
		end
		ent:SetTeamID(teamid)
		ent:Spawn()
		owner:SetMana(math.max(0, owner:GetMana() - 4), true)
	end

	local _filter = player.GetAll()
	table.Add(_filter, ents.FindByClass("ice_path"))
	local tr2 = util.TraceLine({start = pos, endpos = pos + Vector(0, 0, 1000), filter=_filter, mask = MASK_SOLID})
	local tr = util.TraceLine({start = tr2.HitPos, endpos = tr2.HitPos + Vector(0, 0, -10000), filter=_filter, mask = MASK_WATER + MASK_SOLID})
	if tr.Hit and tr.MatType == 83 then
		local ent2 = ents.Create("iceburg")
		if ent2:IsValid() then
			ent2:SetPos(tr.HitPos + Vector(0,0,-48))
			ent2:Spawn()
			for _, pl in pairs(ents.FindInSphere(tr.HitPos,40)) do
				if pl:IsPlayer() then
					ent2:Remove()
				end
			end
		end
	end
end

function SWEP:WeaponMeleeAttack(owner)
	local eyepos = owner:GetShootPos()
	local ownerteam = owner:Team()
	local worldfilter = player.GetAll()
	table.Add(worldfilter, ents.FindByClass("vehiclepart"))
	table.insert(worldfilter, self)
	local trace = util.TraceLine({start = eyepos, endpos = eyepos + owner:GetAimVector() * 100, filter = worldfilter, mask = MASK_SOLID})

	if trace.Hit and not trace.HitSky then
		if owner:GetStatus("spellsaber_shockblade") then
			if owner:GetMana() >= 15 then
				if owner:IsCarrying() or owner:GetStatus("anchor") then return end
				owner:SetMana(math.max(0, owner:GetMana() - 15), true)
				local effectdata = EffectData()
					effectdata:SetOrigin(trace.HitPos)
					effectdata:SetNormal(trace.HitNormal)
					SuppressHostEvents(NULL)
				util.Effect("shockwave", effectdata)
				owner:SetGroundEntity(NULL)
				owner:SetVelocity(Vector(0,0, owner:GetAimVector().z * -500))
				owner:Fire("ignorefalldamage", "2.5", 0)
			else
				owner:SendLua("insma()")
			end
		end
		if owner:GetStatus("spellsaber_nullblade") then
			if owner:GetMana() >= 20 then
				owner:SetMana(math.max(0, owner:GetMana() - 20), true)
				local effectdata = EffectData()
					effectdata:SetOrigin(trace.HitPos)
					SuppressHostEvents(NULL)
				util.Effect("nullexplode", effectdata)

				CounterSpellEffect(owner, trace.HitPos, 256)
			else
				owner:SendLua("insma()")
			end
		end
	end

	if owner:GetStatus("blade_spirit") then
		local blades = owner:GetStatus("blade_spirit"):GetBlades()
		owner:GetStatus("blade_spirit"):SetBlades(blades - 1)
		owner:EmitSound("npc/roller/blade_out.wav", 80, math.Rand(95, 105))
		local ent = ents.Create("projectile_blade_spirit")
		if ent:IsValid() then
			ent:SetOwner(owner)
			ent:SetTeamID(owner:Team())
			ent:SetPos(owner:GetShootPos())
			ent:Spawn()
			ent:SetAngles(owner:EyeAngles())
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				phys:SetVelocity(owner:GetAimVector() * 1500)
			end
		end
	end

	if owner:GetStatus("spellsaber_frostblade") then
		if owner:GetMana() >= 4 then
			local vStart = owner:GetPos() + Vector(0,0,32)
			local vForward = owner:GetAngles():Forward()
			local _filter = player.GetAll()
			table.Add(_filter, ents.FindByClass("ice_path"))

			local tocreate = {}

			local dist = 64
			for i=1, 5 do
				local tr = util.TraceLine({start = vStart, endpos = dist * vForward + vStart, filter = _filter, mask = MASK_SOLID})
				local tr2 = util.TraceLine({start = tr.HitPos, endpos = tr.HitPos + Vector(0, 0, -100), filter = _filter, mask = MASK_SOLID + MASK_WATER})

				if tr2.Hit then
					dist = dist + 80
					table.insert(tocreate, tr2.HitPos)
				end

				if tr.Hit then break end
			end

			if #tocreate <= 0 then return true end

			local teamid = owner:GetTeamID()
			for i, pos in ipairs(tocreate) do
				timer.Simple(i * 0.1, function() CreateIcePath( owner, pos, teamid) end)
			end
		else
			owner:SendLua("insma()")
		end
	end
end
