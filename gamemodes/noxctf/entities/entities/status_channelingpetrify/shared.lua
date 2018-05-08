ENT.Type = "anim"
ENT.Base = "status__base"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.StartSound = {sound = Sound("ambient/machines/machine1_hit"..math.random(1,2)..".wav"), vol = 80, pitchLB = 70, pitchRB = 80}
ENT.StatusImage = "spellicons/aurify.png"

ENT.CounterSpell = COUNTERSPELL_DESTROY

ENT.MaxRange = 512
ENT.ManaPerSecond = 15
ENT.TickTime = .2

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "Target")
end

function ENT:TranslateActivity(pl, act)
	if pl ~= self:GetOwner() then return end

	return GAMEMODE.BaseActivityTranslate(act, ACT_HL2MP_IDLE_MAGIC)
end

function ENT:GetStartPos()
	local owner = self:GetOwner()
	if owner:IsValid() then
		return owner:GetShootPos()
	end

	return self:GetPos()
end

function ENT:IsValidTarget(target)
	local owner = self:GetOwner()
	if target:IsValid() and target:IsPlayer() and target:Alive() and not target:InVehicle() and target:Team() ~= self:GetOwner():Team() and owner:IsFacing(target) and (self:GetTarget() == target or target:IsVisibleTarget(owner)) and not target:GetStatus("petrify") then
		local startpos = self:GetStartPos()
		local targetpos = target:NearestPoint(startpos)
		if targetpos:Distance(startpos) <= self.MaxRange and TrueVisible(startpos, targetpos) then
			return true
		end
	end

	return false
end

function ENT:HasValidTarget()
	return self:IsValidTarget(self:GetTarget())
end

function ENT:Move(pl, move)
	local target = self:GetTarget()
	if not target:IsValid() then return end

	if pl ~= target or pl:GetStatus("dragoonflight") or (pl.GrappleBeam and pl.GrappleBeam:IsValid() and pl.GrappleBeam:GetSkin() == 1) or pl:GetStatus("berserkercharge") or pl.HealRing or pl.ChargeFireBall or pl:GetStatus("stun") or pl:GetStatus("stun_noeffect") then return end
	
	local delta = (self:GetDieTime() - CurTime())/self.LifeTime
	local speed = 200 * delta
	move:SetMaxSpeed(speed)
	move:SetMaxClientSpeed(speed)
end
