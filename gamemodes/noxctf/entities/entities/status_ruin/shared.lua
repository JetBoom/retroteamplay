ENT.Type = "anim"
ENT.Base = "status__base"
ENT.Hostile = true

ENT.StartSound = {sound = Sound("ambient/levels/canals/toxic_slime_sizzle3.wav"), vol = 100, pitchLB = 50, pitchRB = 50}
ENT.StatusImage = "spellicons/ruin.png"

function ENT:EntityTakeDamage(ent, dmginfo)
	local attacker = dmginfo:GetAttacker()
	if attacker == self:GetOwner() then
		local inflictor = dmginfo:GetInflictor()
		if inflictor and inflictor:IsValid() and inflictor.MeleeDamage then
			dmginfo:SetDamage(dmginfo:GetDamage() * 0.9)
		end
	end
end
