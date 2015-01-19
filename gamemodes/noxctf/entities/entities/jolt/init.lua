ENT.Type = "point"

local numjolt = 0

function ENT:Initialize()
	self.DeathTime = CurTime() + math.Rand(2.9, 3.1)
	numjolt = numjolt + 1

	local mypos = self:GetPos()
	local infotarget = ents.Create("info_target")
	if infotarget:IsValid() then
		infotarget:SetPos(util.TraceLine({start=mypos, endpos=mypos+Vector(0, 0, -20000), mask=MASK_SOLID_BRUSHONLY}).HitPos + Vector(math.Rand(-450, 450), math.Rand(-450, 450), -5000))
		infotarget:SetKeyValue("targetname", "jolt"..numjolt)
		infotarget:Spawn()
	end

	local laser = ents.Create("env_laser")
	if laser:IsValid() then
		laser:SetPos(mypos)
		laser:SetKeyValue("renderamt", "255")
		laser:SetKeyValue("rendercolor", "255 100 10")
		laser:SetKeyValue("width", tostring(math.random(25, 32)))
		laser:SetKeyValue("texture", "effects/laser1.vmt")
		laser:SetKeyValue("TextureScroll", "24")
		laser:SetKeyValue("damage", "0")
		laser:SetKeyValue("renderfx", "15")
		laser:SetKeyValue("LaserTarget", "jolt"..numjolt)
		laser:SetKeyValue("NoiseAmplitude", "3")
		laser:SetKeyValue("spawnflags", "33")
		laser:Spawn()
		laser:SetOwner(self:GetOwner())
	end

	self.Laser = laser
	self.InfoTarget = infotarget

	self.NextZap = 0
end

function ENT:OnRemove()
	self.Laser:Remove()
	self.InfoTarget:Remove()
end

local function jcb(attacker, tr, dmginfo)
	local hitent = tr.Entity
	if hitent and hitent:IsValid() then
		if string.sub(hitent:GetClass(), 1, 20) == "projectile_dreadnaut" and not hitent.Electricity then
			local pl = attacker:GetOwner()
			if not pl:IsValid() then pl = hitent:GetOwner() end
			if hitent:IsValid() then
				hitent:SetSkin(1)
				if hitent:GetTeamID() == pl:Team() then
					hitent.Electricity = pl
				else
					hitent.Electricity = hitent:GetOwner()
				end
			end
		elseif hitent:GetClass() == "prop_vehiclepad" then
			hitent:TakeSpecialDamage(2, DMGTYPE_GENERIC, attacker:GetOwner(), attacker)
		elseif hitent.PHealth then
			hitent:TakeSpecialDamage(2, DMGTYPE_SHOCK, attacker:GetOwner(), attacker)
		else
			hitent:TakeSpecialDamage(5, DMGTYPE_SHOCK, attacker:GetOwner(), attacker)
		end
	end

	return {effects = false, damage = false}
end

function ENT:Think()
	if self.DeathTime <= CurTime() then
		self:Remove()
		return
	end

	local pos = self.InfoTarget:GetPos()
	self.InfoTarget:SetPos(util.TraceLine({start=pos, endpos=pos+Vector(math.Rand(-48, 48), math.Rand(-48, 48), 0), mask=MASK_SOLID}).HitPos)

	self:FireBullets({Num = 1, Src = self.Laser:GetPos(), Dir = (self.InfoTarget:GetPos() - self.Laser:GetPos()):GetNormal(), Spread = Vector(0, 0, 0), Tracer = 99999, Force = 0, Damage = 0, HullSize = 36, Callback = jcb})
	self:NextThink(CurTime() + 0.2)

	return true
end
