AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Classes = {"Conjurer", "Archer"}
SWEP.NextAttack = 0

SWEP.Droppable = "pickup_longbow"

function SWEP:ReleaseArrow(pl)

	local arrowtype = "projectile_arrow"
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
		local ang = pl:EyeAngles()
		ang:RotateAroundAxis(ang:Forward(), 90)
		ent:SetAngles(ang)
		ent:SetPos(pl:GetShootPos())
		ent.Damage = math.ceil(self.AttackStrength * 25) * (pl:GetStatus("ruin") and 0.9 or 1)
		ent.Force = self.AttackStrength
		ent.AttackStrength = self.AttackStrength
		local teamid = pl:Team()
		local col = team.GetColor(teamid)
		ent:SetColor(Color(col.r, col.g, col.b, 255))
		ent:Spawn()
		ent:SetTeamID(teamid)
		local phys = ent:GetPhysicsObject()
		--print( "Arrow fired with "..tostring(ent.Force).." Force | "..tostring(attackstrength).." AtkStr )" )
		if phys:IsValid() then
				--if arrowtype == "projectile_lightningarrow" || arrowtype == "projectile_grapplearrow" then return end
				--phys:EnableGravity(true)
			if arrowtype == "projectile_lightningarrow" then
				phys:SetVelocityInstantaneous(pl:GetAimVector() * 4000)
			else
				phys:SetVelocityInstantaneous(1900 * ent.Force * pl:GetAimVector())
			end
		end
	end
end

function SWEP:Deploy()
	self.Fidget = nil
	self.Lower = nil
	self.Drawing = nil
	local owner = self.Owner
	owner:DrawViewModel(true)
	owner:RemoveStatus("weapon_*", false, true)
	owner:GiveStatus("weapon_longbow")
end

function SWEP:Holster()
	self.Owner:RemoveStatus("weapon_longbow", false, true)
	return true
end

function SWEP:Think()
	if self.Fidget then
		if not self.Owner:KeyDown(IN_ATTACK) then

			self.Fidget = nil
			self.Lower = CurTime() + 0.75
			self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)

			local pl = self.Owner

			pl:RemoveInvisibility()

			pl:DoAttackEvent()

			self.NextAttack = CurTime() + self.Primary.Delay

			self.AttackStrength = math.max(0.3, math.min(1, 1 - (self.FullPower - CurTime())))

			self.FullPower = nil

			self:ReleaseArrow(pl)

			pl:EmitSound("nox/bow_end.ogg")

		end
	elseif self.Drawing and self.Drawing <= CurTime() then
		self.Fidget = true
		self.Drawing = nil
		self.Lower = nil
		self.FullPower = CurTime() + 1
		self:SendWeaponAnim(ACT_VM_FIDGET)
		self.Owner:EmitSound("nox/bow_start0"..math.random(1,2)..".ogg")
		self:SetWeaponHoldType("smg")
	elseif self.Lower and self.Lower <= CurTime() then
		self.Lower = nil
		self:SendWeaponAnim(ACT_VM_IDLE_LOWERED)
	end
end

function SWEP:PrimaryAttack()
	if self:CanPrimaryAttack() then
		if self.Owner:KeyDown(IN_ATTACK2) then
			self.NextAttack = math.max(self.NextAttack, CurTime() + 0.25)
			return
		end

		self.Lower = nil
		self.Drawing = CurTime() + 0.5
		self:SendWeaponAnim(ACT_VM_IDLE_TO_LOWERED)
		self.Owner:EmitSound("nox/bow_takearrow0"..math.random(1,4)..".ogg")
		self:SetWeaponHoldType("melee")
	end
end
--[[
function SWEP:Reload()
	for _, ent in pairs(ents.FindByClass("projectile_volleyarrow")) do
		if ent:GetOwner() == self.Owner then
			ent:DoVolley()
		end
	end
end]]
