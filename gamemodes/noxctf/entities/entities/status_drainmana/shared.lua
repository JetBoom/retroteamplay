ENT.Type = "anim"
ENT.Base = "status__base"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.StartSound = Sound("nox/manadrain.ogg")
ENT.StatusImage = "spellicons/drainmana.png"

ENT.CounterSpell = COUNTERSPELL_DESTROY

ENT.StartTime = 0.25
ENT.MaxRange = 512
ENT.DrainsPerSecond = 4
ENT.ManaPerDrain = 5

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "Target")
end

function ENT:PlayerCantCastSpell(pl, spellid)
	return spellid == NameToSpell["Energy Bolt"]
end

function ENT:TranslateActivity(pl, act)
	if pl ~= self:GetOwner() then return end

	return GAMEMODE.BaseActivityTranslate(act, ACT_HL2MP_IDLE_MAGIC)
end

function ENT:GetStartPos()
	local owner = self:GetOwner()
	if owner:IsValid() then
		return owner:GetCenter()
	end

	return self:GetPos()
end

function ENT:IsValidTarget(target)
	local owner = self:GetOwner()
	if target:IsValid() and (target.CanBeManaDrained or target:IsPlayer() and target:Alive() and target:Team() ~= self:GetOwner():Team() and target:GetMana() >= 10) and owner:IsFacing(target) then
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
