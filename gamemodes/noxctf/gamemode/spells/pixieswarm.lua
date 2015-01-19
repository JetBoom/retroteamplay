SPELL.Name = "Pixie Swarm"
SPELL.Description = "Conjure a swarm of glowing pixies that surround you and attack all those who draw too close."
SPELL.Mana = 20
SPELL.Classes = {"Conjurer", "Templar"}
SPELL.Words = "et zo cha zo"

SPELL.Icon = "spellicons/pixieswarm.png"

SPELL.Inversable = nil
SPELL.Hostile = true

function SPELL.Cast(pl)
	for _, ent in pairs(ents.FindByClass("projectile_pixie")) do
		if ent:GetOwner() == pl then
			ent:Remove()
		end
	end

	local col = Color(255, 255, 0)
	for i = 1, 4 do
		local ent = ents.Create("projectile_pixie")
		if ent:IsValid() then
			ent:SetPos(pl:GetPos() + Vector(0, 0, 32) + VectorRand() * 16)
			ent:SetOwner(pl)
			ent:Spawn()
			ent:SetTeamID(pl:Team())
			util.SpriteTrail(ent, 0, col, false, 12, 12, 0.1, 0.125, "trails/laser.vmt")
		end
	end

	pl:CustomGesture(ACT_SIGNAL_GROUP)
	pl:EmitSound("nox/pixieswarm.ogg")
end