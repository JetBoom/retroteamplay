ENT.Type = "anim"
ENT.Base = "status__base"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.MaxForceFieldHealth = 75

ENT.StartSound = Sound("nox/shield.ogg")
ENT.EndSound = Sound("nox/shieldoff.ogg")
ENT.StatusImage = "spellicons/forcefield.png"

function ENT:SetupDataTables()
	self:NetworkVar("Float", 0, "ForceFieldHealth")
end

function ENT:ProcessDamage(attacker, inflictor, dmginfo)
	local owner = self:GetOwner()
	if owner:IsValid() then
		local damage = dmginfo:GetDamage()
		local newdamage = damage * 0.75
		dmginfo:SetDamage(newdamage)
		self:SetForceFieldHealth(self:GetForceFieldHealth() - damage)

		local wouldkill = newdamage >= owner:Health()
		if wouldkill or self:GetForceFieldHealth() <= 0 then
			if wouldkill then
				dmginfo:SetDamage(owner:Health() - 1)
			end
			owner:RemoveStatus("forcefield", false, true)
		end
	end
end

util.PrecacheModel("models/hunter/misc/sphere1x1.mdl")
