ENT.Type = "anim"
ENT.Base = "status__base"

ENT.StatusImage = "spellicons/light.png"

function ENT:ProcessDamage(attacker, inflictor, dmginfo)
	local owner = self:GetOwner()
	local pos = owner:GetPos()
	if owner:IsValid() then
		local damage = dmginfo:GetDamage()
		local newdamage = damage * 0.8
		dmginfo:SetDamage(newdamage)
		for _, ent in pairs(ents.FindInSphere(pos, 400)) do
			if ent:IsValid() and ent:IsPlayer() and ent:GetTeamID() == owner:Team() and ent:Alive() and ent:GetStatus("hallowedgroundchanneling") and attacker ~= owner then
				local status = ent:GetStatus("hallowedgroundchanneling")
				status:SetCharges(status:GetCharges() + damage - newdamage)
			end
		end
	end
end
