ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:SetupDataTables()
	self:NetworkVar("Float", 0, "myHealth")
end

function ENT:ProcessDamage(attacker, inflictor, dmginfo)
	if dmginfo:GetDamageType() ~= DMGTYPE_ICE then
		if dmginfo:GetDamageType() == DMGTYPE_FIRE then
			self:SetmyHealth(self:GetmyHealth() - dmginfo:GetDamage() * 2)
		else 
			self:SetmyHealth(self:GetmyHealth() - dmginfo:GetDamage())
		end
	end
end
