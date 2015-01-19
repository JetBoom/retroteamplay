ENT.Type = "anim"
ENT.Base = "status__base"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.StartSound = Sound("nox/protecton.ogg")
ENT.EndSound = Sound("nox/protectoff.ogg")
ENT.StatusImage = "spellicons/sacredvow.png"

ENT.Dist = 800
ENT.SpeedBoost = 30

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "Caster")
end

function ENT:ProcessDamage(attacker, inflictor, dmginfo)
	local caster = self:GetCaster()
	local owner = self:GetOwner()
	
	if caster:IsValid() and caster:Alive() and attacker ~= owner and inflictor:GetClass() ~= "status_sacredvow" and not owner:GetStatus("oversoul") then
		local dmg = dmginfo:GetDamage() * .5
		caster:TakeSpecialDamage(dmg, dmginfo:GetDamageType(), attacker, self)
		dmginfo:SetDamage(dmg)
		local effectdata = EffectData()
			effectdata:SetScale(owner:EntIndex())
			effectdata:SetEntity(caster)
			effectdata:SetMagnitude(dmg)
		util.Effect("sacredvowdamage", effectdata)
	end
end

function ENT:Move(pl, move)
	if pl ~= self:GetCaster() then return end
	local targets = 0
	for _, ent in pairs(ents.FindByClass("status_sacredvow")) do
		if ent:GetCaster() == self:GetCaster() then
			targets = targets + 1
		end
	end
	local speed = move:GetMaxSpeed() + self.SpeedBoost / targets
	move:SetMaxSpeed(speed)
	move:SetMaxClientSpeed(speed)
end
