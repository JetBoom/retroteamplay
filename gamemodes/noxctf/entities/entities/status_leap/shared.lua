ENT.Type = "anim"
ENT.Base = "status__base"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.StartSound = {sound = "nox/airburst.ogg", vol = 100, pitchLB = 120, pitchRB = 120}
ENT.EndSound = {sound = "nox/earthquake.ogg", vol = 100, pitchLB = 120, pitchRB = 120}
ENT.StatusImage = "spellicons/leap2.png"

ENT.JumpVelocity = 1250
ENT.GravityMultiplier = 3
ENT.Damage = 15
ENT.TouchMultiplier = 2
ENT.DamageType = DMGTYPE_IMPACT
ENT.DamageRadius = 125
ENT.Debuff = "slow"
ENT.DebuffDuration = 1
ENT.ZOffset = 150
ENT.XYOffset = 100
ENT.SelfStunDuration = 2.5

function ENT:SetupDataTables()
	self:NetworkVar("Float", 0, "Delta")
	self:NetworkVar("Vector", 0, "EffectPos")
end

function ENT:CanTakeFlag(owner, flag)
	return false
end

function ENT:GetFallDamage(pl, speed)
	if pl ~= self:GetOwner() then return end

	return 0
end