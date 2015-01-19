ENT.Type = "anim"
ENT.Base = "status__base"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.StartSound = Sound("nox/energyboltstart.ogg")
ENT.StatusImage = "spellicons/energybolt.png"

ENT.CounterSpell = COUNTERSPELL_DESTROY

ENT.MaxRange = 512
ENT.ZapsPerSecond = 5
ENT.DamagePerZap = 4
ENT.ManaPerZap = 7
ENT.StartTime = 0.5

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "Target")
	self:NetworkVar("Float", 0, "StartTime")
end

function ENT:PlayerCantCastSpell(pl, spellid)
	return spellid == NameToSpell["Drain Mana"]
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
	if target:IsValid() and target:IsPlayer() and target:Alive() and not target:InVehicle() and target:Team() ~= self:GetOwner():Team() and owner:IsFacing(target) and (self:GetTarget() == target or target:IsVisibleTarget(owner)) then
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
