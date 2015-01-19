SPELL.Name = "Fire Bomb"
SPELL.Description = "Creates a giant flaming ball. The ball explodes shortly after its first bounce."
SPELL.Mana = 80
SPELL.Classes = {"Wizard"}
SPELL.Words = "zo ru un in zo ru"

SPELL.Icon = "spellicons/starburst.png"

SPELL.Inversable = nil
SPELL.Hostile = true

function SPELL.Cast(pl)
	local ent = ents.Create("projectile_firebomb")
	if ent:IsValid() then
		ent:SetOwner(pl)
		ent:SetTeamID(pl:Team())
		ent:SetPos(pl:GetShootPos())
		local c = pl:GetColor()
		ent:SetColor(Color(c.r, c.g, c.b, 255))
		ent:Spawn()
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			local aimvec = pl:GetAimVector()
			aimvec.z = math.max(aimvec.z, 0.35)
			aimvec = aimvec:GetNormal()
			phys:SetVelocityInstantaneous(aimvec * 850)
		end
		util.SpriteTrail(ent, 0, color_white, false, 48, 32, 1, 0.025, "Effects/fire_cloud2.vmt")

		pl:CustomGesture(ACT_SIGNAL_FORWARD)
	end
end