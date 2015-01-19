ENT.Type = "anim"
ENT.Base = "status__base"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.Hostile = true

ENT.StartSound = Sound("beams/beamstart5.wav")
ENT.EndSound = Sound("weapons/physgun_off.wav")
ENT.StatusImage = "spellicons/dispelundead.png"

function ENT:ProcessDamage(attacker, inflictor, dmginfo)
	dmginfo:SetDamage(dmginfo:GetDamage() * 1.5)
end
