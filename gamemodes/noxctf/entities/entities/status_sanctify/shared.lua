ENT.Type = "anim"
ENT.Base = "status__base"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.StatusImage = "spellicons/sanctify.png"

ENT.TotalHeal = 25
ENT.LifeTime = 12.5

function ENT:ProcessDamage(attacker, inflictor, dmginfo)
	dmginfo:SetDamage(dmginfo:GetDamage() * 0.80)
end
