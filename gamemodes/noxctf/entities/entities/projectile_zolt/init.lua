AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.CounterSpell = COUNTERSPELL_DESTROY

function ENT:Initialize()
	self:DrawShadow(false)
	self:PhysicsInitSphere(16)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(true)
		phys:EnableDrag(false)
		phys:EnableGravity(false)
		phys:Wake()
	end

	self.CoolDown = 0
	self.DeathTime = CurTime() + 10
	self.AlreadyHit = {}
end

function ENT:Think()
	if self.DeathTime <= CurTime() then
		self:Remove()
		return
	end

	if self.PhysicsData then
		self:Explode(self.PhysicsData.HitPos, self.PhysicsData.HitNormal)
	end

	if self.CoolDown > CurTime() then return end

	local mypos = self:GetPos()

	local owner = self:GetOwner()
	if not owner:IsValid() then owner = self end

	local myteam = self:GetTeamID()
	local target = NULL
	local cdist = math.huge
	for k, v in pairs(ents.FindInBox(mypos + Vector(-55, -55, -4096), mypos + Vector(55, 55, 0))) do
		if not self.AlreadyHit[v] then
			if v:IsPlayer() then -- players
				local nearest = v:NearestPoint(mypos)
				if v:Team() ~= myteam and v:Alive() and TrueVisible(nearest, mypos) then -- only enemy team members left    
					local compdist = nearest:Distance(mypos)
					if compdist < cdist and v:Alive() then 
						target = v 
						cdist = compdist
					end
				end
			elseif (string.sub(v:GetClass(), 1, 20) == "projectile_dreadnaut" or string.sub(v:GetClass(), 1, 19) == "projectile_volcanic") and not v.Electricity then
				local vpos = v:NearestPoint(mypos)
				local compdist = vpos:Distance(mypos)
				if compdist < cdist and TrueVisible(mypos, vpos) then 
					target = v 
					cdist = compdist
				end
			end
		end
	end

	if not target:IsValid() then return end

	self.AlreadyHit[target] = true

	self.CoolDown = CurTime() + 0.15

	local bottompos
	if target:IsPlayer() then
		target:SendLua("ZoltStruckMe()")

		bottompos = target:LocalToWorld(target:OBBCenter())
		target:TakeSpecialDamage(30, DMGTYPE_LIGHTNING, owner, self, bottompos)
	else
		bottompos = target:GetPos()
		target:SetSkin(1)
		if target:GetTeamID() == myteam then
			target.Electricity = owner
		else
			target.Electricity = target:GetOwner()
		end
	end

	local tempent = ents.Create("info_target")
	local targetname = owner:EntIndex().."templighttarget"..math.random(0, 10000)
	if tempent:IsValid() then
		tempent:SetPos(bottompos)
		tempent:SetName(targetname)
		tempent:Spawn()
		if target:IsValid() then
			tempent:SetParent(target)
		end
		tempent:Fire("kill", "", 0.41)
	end

	local laser = ents.Create("env_laser")
	if laser:IsValid() then
		laser:SetPos(mypos)
		laser:SetKeyValue("renderamt", "255")
		laser:SetKeyValue("rendercolor", "21 106 234")
		laser:SetKeyValue("width", "30")
		laser:SetKeyValue("texture", "Effects/laser1.vmt")
		laser:SetKeyValue("TextureScroll", "1")
		laser:SetKeyValue("damage", "0")
		laser:SetKeyValue("renderfx", "0")
		laser:SetKeyValue("LaserTarget", targetname)
		laser:SetKeyValue("NoiseAmplitude", "4")
		laser:SetKeyValue("spawnflags", "33")
		laser:Spawn()
		laser:SetParent(self)
		laser:SetOwner(owner)
		laser:Fire("kill", "", 0.75)
	end
	local effect2 = ents.Create("point_tesla")
	if effect2:IsValid() then
		effect2:SetKeyValue("m_flRadius", "250")
		effect2:SetKeyValue("m_SoundName", "DoSpark")
		effect2:SetKeyValue("m_Color", "255 255 255")
		effect2:SetKeyValue("texture", "effects/laser1.vmt")
		effect2:SetKeyValue("beamcount_min", "6")
		effect2:SetKeyValue("beamcount_max", "10")
		effect2:SetKeyValue("thick_min", "20")
		effect2:SetKeyValue("thick_max", "50")
		effect2:SetKeyValue("lifetime_min", "0.5")
		effect2:SetKeyValue("lifetime_max", "1")
		effect2:SetKeyValue("interval_min", "0.1")
		effect2:SetKeyValue("interval_max", "0.25")
		effect2:SetParent(self)
		effect2:SetPos(bottompos + Vector(0,0,32))
		effect2:Spawn()
		if target:IsValid() then
			effect2:SetParent(target)
		end
		effect2:Fire("DoSpark", "", 0.1)
		effect2:Fire("DoSpark", "", 0.3)
		effect2:Fire("DoSpark", "", 0.5)
		effect2:Fire("kill", "", 0.8)
	end

	local effectdata = EffectData()
		effectdata:SetOrigin(bottompos)
	util.Effect("lightning", effectdata)

	util.ScreenShake(bottompos, math.Rand(10, 30), 150.0, 0.75, 150)
end

function ENT:PhysicsCollide(data, phys)
	self:Explode(data.HitPos, data.HitNormal)
	self:NextThink(CurTime())
end

function ENT:Explode(hitpos, hitnormal)
	if self.Exploded then return end
	self.Exploded = true
	self.DeathTime = 0

	local owner = self:GetOwner()
	if not owner:IsValid() then owner = self end

	ExplosiveDamage(owner, hitpos, 40, 10, 0, 1, 10, self, DMGTYPE_SHOCK)

	self:NextThink(CurTime())
end
