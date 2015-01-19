include("shared.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

function ENT:Initialize()
	self.PoisonCounter = {}

	self.DeathTime = CurTime() + 6
	self:SetStartTime(CurTime() + 1)
	self.Electrified = false
	self:DrawShadow(false)
	self.Laser = {}
	self.InfoTarget = {}
end

function ENT:Think()
	if self.DeathTime <= CurTime() then
		self:Remove()
		return
	end

	if CurTime() < self:GetStartTime() then return end

	local owner = self:GetOwner()
	if not owner:IsValid() then owner = self end

	local pos = self:GetPos()
	for _, ent in pairs(ents.FindInBox(pos + Vector(-230, -230, -2000), pos + Vector(230, 230, 0))) do
		if ent:IsValid() and ent:IsPlayer() and ent:Alive() and (ent:Team() ~= owner:Team() or ent == owner) and TrueVisible(pos, ent:NearestPoint(pos)) then
			self.PoisonCounter[ent] = (self.PoisonCounter[ent] or 0) + 1
			if self.PoisonCounter[ent] == 12 then
				ent:Poison(5)
			end

			ent:TakeSpecialDamage(3, DMGTYPE_POISON, owner, self)
			ent:EmitSound("player/pl_pain"..math.random(5, 7)..".wav")
		end
		if self.Electrified then
			if (ent:GetClass() == "projectile_dreadnautbomb" or string.sub(ent:GetClass(), 1, 19) == "projectile_volcanic") and not ent.Electricity then
				local owner = self.ElecOwner
				local elecowner = owner
				if not owner:IsValid() then elecowner = ent:GetOwner() end
					if ent:IsValid() then
						ent:SetSkin(1)
					if ent:GetTeamID() == elecowner:Team() then
						ent.Electricity = elecowner
					else
						ent.Electricity = ent:GetOwner()
					end
				end
			elseif ent:IsValid() and (ent:GetTeamID() ~= owner:Team() or ent == owner or ent == self.ElecOwner) and TrueVisible(pos, ent:NearestPoint(pos)) then
				if ent:IsPlayer() and ent:Alive() then
					ent:TakeSpecialDamage(4, DMGTYPE_SHOCK, self.ElecOwner, self)
				else
					ent:TakeSpecialDamage(2, DMGTYPE_SHOCK, self.ElecOwner, self)
				end
			end
		end
	end

	if not self.Electrified then
		for _, ent in pairs(ents.FindInSphere(pos, 250)) do
			if ent:GetClass() == "projectile_electronball" or ent:GetClass() == "projectile_sparkler" or ent:GetClass() == "projectile_staticball" or ent:GetClass() == "projectile_zolt" or ent:GetClass() == "projectile_lightningarrow" then
				self.ElecOwner = ent:GetOwner()
				ent:Remove()
				self:EmitSound("ambient/levels/labs/electric_explosion"..math.random(1,5)..".wav", 150, 100)
				self.DeathTime = self.DeathTime + 6
				for i=1,8 do
					local infotarget = ents.Create("info_target")
					if infotarget:IsValid() then
						infotarget:SetPos(util.TraceLine({start=pos, endpos=pos+Vector(0, 0, -20000), mask=MASK_SOLID_BRUSHONLY}).HitPos + Vector(math.Rand(-500, 500), math.Rand(-500, 500), -5000))
						infotarget:SetKeyValue("targetname", "jolt"..i)
						infotarget:Spawn()
					end

					local laser = ents.Create("env_laser")
					if laser:IsValid() then
						laser:SetPos(pos + Vector(math.Rand(-200,200),math.Rand(-200,200),0))
						laser:SetKeyValue("renderamt", "255")
						laser:SetKeyValue("rendercolor", "255 100 10")
						laser:SetKeyValue("width", tostring(math.random(25, 32)))
						laser:SetKeyValue("texture", "effects/laser1.vmt")
						laser:SetKeyValue("TextureScroll", "24")
						laser:SetKeyValue("damage", "0")
						laser:SetKeyValue("renderfx", "15")
						laser:SetKeyValue("LaserTarget", "jolt"..i)
						laser:SetKeyValue("NoiseAmplitude", "3")
						laser:SetKeyValue("spawnflags", "33")
						laser:Spawn()
						laser:SetOwner(self:GetOwner())
					end
					self.Laser[i] = laser
					self.InfoTarget[i] = infotarget
				end
				self.Electrified = true
			end
		end
	end
	
	self:NextThink(CurTime() + 0.2) 
	return true
end

function ENT:OnRemove()
	if self.Electrified then
		for i=1,8 do
			self.Laser[i]:Remove()
			self.InfoTarget[i]:Remove()
		end
	end
end
