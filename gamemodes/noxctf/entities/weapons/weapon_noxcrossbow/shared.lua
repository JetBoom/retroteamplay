SWEP.ViewModel = "models/weapons/v_crossbow.mdl"
SWEP.WorldModel = "models/weapons/w_crossbow.mdl"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 1
SWEP.Primary.Damage = 40

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

SWEP.Droppable = "pickup_crossbow"

function SWEP:Initialize()
	self:SetWeaponHoldType("crossbow")
end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	local pl = self.Owner
	
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:SetReloaded(false)

	pl:DoAttackEvent()
	pl:EmitSound("nox/crossbowfire.ogg")
	pl:ViewPunch(Angle(-20, 0, 0))

	if SERVER then
		pl:RemoveInvisibility()

		local arrowtype = "projectile_crossbowbolt"
		if pl:GetStatus("archerenchant_fire") then
			arrowtype = "projectile_firearrow"
			pl:RemoveStatus("archerenchant_*", false, true)
		elseif pl:GetStatus("archerenchant_detonator") then
			arrowtype = "projectile_detonatorarrow"
			pl:RemoveStatus("archerenchant_*", false, true)
		elseif pl:GetStatus("archerenchant_lightning") then
			arrowtype = "projectile_lightningarrow"
			pl:RemoveStatus("archerenchant_*", false, true)
		elseif pl:GetStatus("archerenchant_vampiric") then
			arrowtype = "projectile_vampiricarrow"
			pl:RemoveStatus("archerenchant_*", false, true)
		elseif pl:GetStatus("archerenchant_silver") then
			arrowtype = "projectile_silverarrow"
			pl:RemoveStatus("archerenchant_*", false, true)
		elseif pl:GetStatus("archerenchant_bouncer") then
			arrowtype = "projectile_bouncerarrow"
			pl:RemoveStatus("archerenchant_*", false, true)
		elseif pl:GetStatus("archerenchant_sprite") then
			arrowtype = "projectile_spritearrow"
			pl:RemoveStatus("archerenchant_*", false, true)
		elseif pl:GetStatus("archerenchant_volley") then
			arrowtype = "projectile_volleyarrow"
			pl:RemoveStatus("archerenchant_*", false, true)
		elseif pl:GetStatus("archerenchant_grapple") then
			arrowtype = "projectile_grapplearrow"
			pl:RemoveStatus("archerenchant_*", false, true)
			if pl.GrappleBeam and pl.GrappleBeam:IsValid() then
				pl.GrappleBeam:Remove()
				pl.GrappleBeam = nil
			end
		end

		local ent = ents.Create(arrowtype)
		if ent:IsValid() then
			ent:SetOwner(pl)
			ent:SetPos(pl:GetShootPos())
			local ang = pl:EyeAngles()
			ang:RotateAroundAxis(ang:Forward(), 90)
			ent:SetAngles(ang)
			ent.Damage = self.Primary.Damage * (pl:GetStatus("ruin") and 2/3 or 1)
			ent.AttackStrength = 1
			local teamid = pl:Team()
			local c = team.GetColor(teamid)
			ent:SetColor(Color(c.r, c.g, c.b, 255))
			ent:Spawn()
			ent:SetTeamID(teamid)
			if arrowtype == "projectile_crossbowbolt" then
				ent.HitAlready = ent.HitAlready or {}
				ent.HitAlready[pl] = true
			end
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				if arrowtype == "projectile_lightningarrow" then
					phys:SetVelocityInstantaneous(pl:GetAimVector() * 4000)
				else
					phys:SetVelocityInstantaneous(pl:GetAimVector() * 2500 * (pl:GetStatus("ruin") and 2/3 or 1))
				end
			end
		end
	end
end

function SWEP:CanPrimaryAttack()
	if not self:IsReloaded() then return false end

	if self.Owner:KeyDown(IN_ATTACK2) then
		self:SetNextPrimaryFire(math.max(self:GetNextPrimaryFire(), CurTime() + 0.05))
		return false
	end

	return CurTime() >= self:GetNextPrimaryFire()
end

function SWEP:CanSecondaryAttack()
	return false
end

function SWEP:Reload()
	if self:GetReloadEnd() == 0 and not self:IsReloaded() and self.Owner:OnGround() then
		self:SendWeaponAnim(ACT_VM_RELOAD)
		local duration = self:SequenceDuration()
		self:SetReloadEnd(CurTime() + duration)
		self:EmitSound("weapons/crossbow/reload1.wav")
		self.Owner:CustomGesture(ACT_HL2MP_GESTURE_RELOAD_AR2)

		if SERVER then
			self.Owner:Slow(duration, true)
			self.Owner:GiveStatus("weight", duration)
		end
	end
end

function SWEP:Think()
	if self:GetReloadEnd() > 0 and CurTime() >= self:GetReloadEnd() then
		self:SetReloadEnd(0)
		self:SetReloaded(true)
	end
end

function SWEP:IsReloaded() return not self:GetDTBool(0) end
function SWEP:SetReloaded(reloaded) self:SetDTBool(0, not reloaded) end
function SWEP:SetReloadEnd(time) self:SetDTFloat(0, time) end
function SWEP:GetReloadEnd() return self:GetDTFloat(0) end
