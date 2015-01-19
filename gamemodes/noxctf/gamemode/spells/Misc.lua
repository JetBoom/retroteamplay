function GreaterHealing(pl, target, health, uid, targetuid)
	if pl:IsValid() and not (pl.CounterSpelled and CurTime() < pl.CounterSpelled) and pl:Alive() and pl:GetVelocity():Length() < 20 and health <= pl:Health() and target:IsValid() and target:Alive() and 4 < pl:GetMana() and target:GetPos():Distance(pl:GetPos()) <= 256 and target:Health() < target:GetMaxHealth() and TrueVisible(pl:EyePos(), target:NearestPoint(pl:EyePos())) then
		pl:SetMana(math.max(pl:GetMana() - 4, 0), true)
		GAMEMODE:PlayerHeal(target, pl, 4)
		if pl ~= target then
			local effectdata = EffectData()
				effectdata:SetOrigin(pl:GetPos())
				effectdata:SetStart(target:GetPos())
			util.Effect("greaterheal", effectdata)
		end
		timer.Create(uid.."GreaterHealing"..targetuid, 0.2, 0, function() GreaterHealing(pl, target, pl:Health(), uid, targetuid) end)
		return
	end
	timer.Destroy(uid.."GreaterHealing"..targetuid)
end

function CounterSpellEffect(pl, pos, range)
	local myteam = pl:Team()
	local counteredsomething = false
	for _, ent in pairs(ents.FindInSphere(pos, range or 450)) do
		if ent.CounterSpell then
			local owner = ent
			local towner = ent:GetOwner()
			if towner:IsPlayer() then
				owner = towner
			end
			if (ent:GetTeamID() ~= myteam or pl == owner) and TrueVisible(ent:NearestPoint(pos), pos)  then
				counteredsomething = true
				local effectdata = EffectData()
					effectdata:SetOrigin(ent:GetPos())
				util.Effect("counterspell", effectdata, true)
				if ent.CounterSpell == COUNTERSPELL_CUSTOM then
					ent:CounterSpelled(pl)
				elseif ent.CounterSpell == COUNTERSPELL_DESTROY then
					ent:Remove()
				elseif ent.CounterSpell == COUNTERSPELL_EXPLODE then
					ent:SetOwner(pl)
					ent:SetTeamID(myteam)
					ent:Explode()
				end
			end
		elseif ent:IsPlayer() and TrueVisible(ent:NearestPoint(pos), pos) then
			ent.CounterSpelled = CurTime() + 0.2
		end
	end
	if not counteredsomething then
		sound.Play("nox/counterspell.ogg", pos, 90, math.random(95, 105))
	end
end

function DoForceOfNature(pl, uid)
	if not (pl:IsValid() and pl:Alive()) then
		return
	end

	local aimvec = pl:GetAimVector()
	local ent = ents.Create("projectile_forceofnature")
	if ent:IsValid() then
		ent:SetPos(pl:GetShootPos())
		ent:SetOwner(pl)
		local teamid = pl:Team()
		ent:SetSkin(teamid)
		ent:Spawn()
		ent:SetTeamID(teamid)
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetVelocityInstantaneous(pl:GetAimVector() * 600)
		end
	end
end

function CreateTeleportCloud(pos1, pos2, pl)
	local ent = ents.Create("teleportcloud")
	if ent:IsValid() then
		ent:SetPos(pos1)
		ent.TargetPos = pos2
		ent.Target = ent2
		if pl then
			ent.Owner = pl
			ent:SetTeamID(pl:Team())
		else
			ent.Owner = ent
			ent:SetTeamID(0)
		end
		ent:Spawn()
		ent:Think()
	end

	local effectdata = EffectData()
		effectdata:SetOrigin(pos1)
	util.Effect("teleportsparksstart", effectdata, true)
end

function DoTeleportToTarget(pl, tr)
	tr.HitPos = tr.HitPos + tr.HitNormal * 0.01

	local vStart = tr.HitPos + Vector(0,0,37)
	if tr.Hit then
		vStart = vStart + tr.HitNormal * 2
	end

	local hits = 0

	local tr2 = util.TraceLine({start = vStart, endpos = vStart + Vector(17,17,37), filter=pl, mask=MASK_PLAYERSOLID})
	if tr2.Hit then
		vStart = vStart + tr2.HitNormal * Vector(17,17,37):Length()
		tr.HitPos = vStart - Vector(0,0,37)
		hits = hits + 1
	end
	tr2 = util.TraceLine({start = vStart, endpos = vStart + Vector(17,17,-37), filter=pl, mask=MASK_PLAYERSOLID})
	if tr2.Hit then
		vStart = vStart + tr2.HitNormal * Vector(17,17,-37):Length()
		tr.HitPos = vStart - Vector(0,0,37)
		if tr2.HitNormal.z < 0.9 then
			hits = hits + 1
		end
	end

	tr2 = util.TraceLine({start = vStart, endpos = vStart + Vector(-17,17,37), filter=pl, mask=MASK_PLAYERSOLID})
	if tr2.Hit then
		vStart = vStart + tr2.HitNormal * Vector(-17,17,37):Length()
		tr.HitPos = vStart - Vector(0,0,37)
		hits = hits + 1
	end
	tr2 = util.TraceLine({start = vStart, endpos = vStart + Vector(-17,17,-37), filter=pl, mask=MASK_PLAYERSOLID})
	if tr2.Hit then
		vStart = vStart + tr2.HitNormal * Vector(-17,17,-37):Length()
		tr.HitPos = vStart - Vector(0,0,37)
		if tr2.HitNormal.z < 0.9 then
			hits = hits + 1
		end
	end

	tr2 = util.TraceLine({start = vStart, endpos = vStart + Vector(0,0,37), filter=pl, mask=MASK_PLAYERSOLID})
	if tr2.Hit then
		vStart = vStart + tr2.HitNormal * 37
		tr.HitPos = vStart - Vector(0,0,37)
		hits = hits + 1
	end
	tr2 = util.TraceLine({start = vStart, endpos = vStart + Vector(0,0,-37), filter=pl, mask=MASK_PLAYERSOLID})
	if tr2.Hit then
		vStart = vStart + tr2.HitNormal * 37
		tr.HitPos = vStart - Vector(0,0,37)
		if tr2.HitNormal.z < 0.9 then
			hits = hits + 1
		end
	end

	tr2 = util.TraceLine({start = vStart, endpos = vStart + Vector(17,-17,37), filter=pl, mask=MASK_PLAYERSOLID})
	if tr2.Hit then
		vStart = vStart + tr2.HitNormal * Vector(17,-17,37):Length()
		tr.HitPos = vStart - Vector(0,0,37)
		hits = hits + 1
	end
	tr2 = util.TraceLine({start = vStart, endpos = vStart + Vector(17,-17,-37), filter=pl, mask=MASK_PLAYERSOLID})
	if tr2.Hit then
		vStart = vStart + tr2.HitNormal * Vector(17,-17,-37):Length()
		tr.HitPos = vStart - Vector(0,0,37)
		if tr2.HitNormal.z < 0.9 then
			hits = hits + 1
		end
	end


	tr2 = util.TraceLine({start = vStart, endpos = vStart + Vector(-17,-17,37), filter=pl, mask=MASK_PLAYERSOLID})
	if tr2.Hit then
		vStart = vStart + tr2.HitNormal * Vector(-17,-17,37):Length()
		tr.HitPos = vStart - Vector(0,0,37)
		hits = hits + 1
	end
	tr2 = util.TraceLine({start = vStart, endpos = vStart + Vector(-17,-17,-37), filter=pl, mask=MASK_PLAYERSOLID})
	if tr2.Hit then
		vStart = vStart + tr2.HitNormal * Vector(-17,-17,-37):Length()
		tr.HitPos = vStart - Vector(0,0,37)
		if tr2.HitNormal.z < 0.9 then
			hits = hits + 1
		end
	end

	tr2 = util.TraceLine({start = vStart, endpos = vStart + Vector(0,17,0), filter=pl, mask=MASK_PLAYERSOLID})
	if tr2.Hit then
		vStart = vStart + tr2.HitNormal * 17
		tr.HitPos = vStart - Vector(0,0,37)
		hits = hits + 1
	end
	tr2 = util.TraceLine({start = vStart, endpos = vStart + Vector(0,-17,0), filter=pl, mask=MASK_PLAYERSOLID})
	if tr2.Hit then
		vStart = vStart + tr2.HitNormal * 17
		tr.HitPos = vStart - Vector(0,0,37)
		hits = hits + 1
	end

	tr2 = util.TraceLine({start = vStart, endpos = vStart + Vector(17,0,0), filter=pl, mask=MASK_PLAYERSOLID})
	if tr2.Hit then
		vStart = vStart + tr2.HitNormal * 17
		tr.HitPos = vStart - Vector(0,0,37)
		hits = hits + 1
	end
	tr2 = util.TraceLine({start = vStart, endpos = vStart + Vector(-17,0,0), filter=pl, mask=MASK_PLAYERSOLID})
	if tr2.Hit then
		vStart = vStart + tr2.HitNormal * 17
		tr.HitPos = vStart - Vector(0,0,37)
		hits = hits + 1
	end

	for _, v in pairs(ents.FindByClass("prop_anchorbeacon")) do
		if v:GetPos():Distance(tr.HitPos) <= v.Radius and v:ShouldAnchor(pl) then
			pl:LM(61)
			return true
		end
	end

	if 6 <= hits or not TrueVisible(pl:EyePos(), tr.HitPos) then
		pl:LM(37)
		return true
	end

	CreateTeleportCloud(pl:GetPos() + Vector(0,0,1), tr.HitPos, pl)
end