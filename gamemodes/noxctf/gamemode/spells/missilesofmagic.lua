SPELL.Name = "Missiles of Magic"
SPELL.Description = "Create four homing balls of fire that explode on impact."
SPELL.Mana = 20
SPELL.Classes = {"Wizard", "Dragoon"}
SPELL.Words = "et cha un cha un"

SPELL.Icon = "spellicons/missilesofmagic.png"

SPELL.Inversable = nil
SPELL.Hostile = true

function SPELL.Cast(pl)
	local count = 0
	for _, ent in pairs(ents.FindByClass("projectile_magicmissile")) do
		if not ent.DontCount and ent:GetOwner() and ent:GetOwner() == pl then
			count = count + 1
		end
	end
	if 8 <= count then
		pl:LMR(36)
		return true
	end

	pl:EmitSound("nox/missilesofmagic.ogg")

	local created = 0
	for i=1, 8 do
		if 4 <= created or 8 <= count then return end

		local aimvec = pl:EyeAngles()
		aimvec.yaw = aimvec.yaw + math.Rand(-15, 15)
		aimvec.pitch = aimvec.pitch + math.Rand(-5, 5)
		aimvec = aimvec:Forward()
		local ent = ents.Create("projectile_magicmissile")
		if ent:IsValid() then
			ent:SetPos(pl:GetShootPos())
			ent:SetOwner(pl)
			ent.Infravision = pl.Infravision
			ent:Spawn()
			ent:SetTeamID(pl:Team())
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				phys:Wake()
				phys:ApplyForceCenter(aimvec * 480)
			end
			created = created + 1
			count = count + 1
		end
	end
end