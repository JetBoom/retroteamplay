ENT.Type = "anim"
ENT.Base = "status__base"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.StartSound = {sound = Sound("nox/shield.ogg"), vol = 100, pitchLB = 50, pitchRB = 50}
ENT.EndSound = Sound("nox/protectoff.ogg")
ENT.StatusImage = "spellicons/oversoul.png"

function ENT:ProcessDamage(attacker, inflictor, dmginfo)
	dmginfo:SetDamage(0)
end
