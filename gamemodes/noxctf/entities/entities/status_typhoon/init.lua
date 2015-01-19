AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:PlayerSet(pPlayer, bExists)
	self:EmitSound("ambient/wind/windgust_strong.wav", 85, 220)
	self:EmitSound("ambient/wind/windgust.wav")
	
	pPlayer:Slow(self:GetDieTime() - CurTime(), true)

	local tempx = ents.Create("env_smokestack")
	if tempx:IsValid() then
		tempx:SetKeyValue("InitialState", "0")
		tempx:SetKeyValue("BaseSpread", "128")
		tempx:SetKeyValue("SpreadSpeed", "512")
		tempx:SetKeyValue("Speed", "512")
		tempx:SetKeyValue("startsize", "32")
		tempx:SetKeyValue("EndSize", "64")
		tempx:SetKeyValue("Rate", "65")
		tempx:SetKeyValue("JetLength", "1500")
		tempx:SetKeyValue("SmokeMaterial", "particle/SmokeStack.vmt")
		tempx:SetKeyValue("twist", "512")
		tempx:SetKeyValue("roll", "64")
		tempx:SetKeyValue("rendercolor", "50 50 50")
		tempx:SetKeyValue("renderamt", "210")
		tempx:SetPos(pPlayer:GetPos() + Vector(0, 0, 16))
		tempx:Spawn()
		tempx:Fire("TurnOn", "", 0)
		tempx:Fire("TurnOff", "", 5)
		tempx:Fire("kill", "", 10)
	end
	self.tempx1 = tempx
	tempx:SetParent(pPlayer)
	local tempx = ents.Create("env_smokestack")
	if tempx:IsValid() then
		tempx:SetAngles(Angle(90, 0, 0))
		tempx:SetKeyValue("InitialState", "0")
		tempx:SetKeyValue("BaseSpread", "128")
		tempx:SetKeyValue("SpreadSpeed", "64")
		tempx:SetKeyValue("Speed", "200")
		tempx:SetKeyValue("startsize", "60")
		tempx:SetKeyValue("EndSize", "80")
		tempx:SetKeyValue("Rate", "10")
		tempx:SetKeyValue("JetLength", "1500")
		tempx:SetKeyValue("SmokeMaterial", "particle/SmokeStack.vmt")
		tempx:SetKeyValue("twist", "512")
		tempx:SetKeyValue("roll", "64")
		tempx:SetKeyValue("rendercolor", "100 100 100")
		tempx:SetKeyValue("renderamt", "210")
		tempx:SetPos(pPlayer:GetPos() + Vector(0, 0, 16))
		tempx:Spawn()
		tempx:Fire("TurnOn", "", 0)
		tempx:Fire("TurnOff", "", 5)
		tempx:Fire("kill", "", 10)
	end
	self.tempx2 = tempx
	tempx:SetParent(pPlayer)
end

function ENT:StatusShouldRemove(owner)
	local tr = util.TraceLine({start = owner:GetPos() + Vector(0,0,16), endpos = owner:GetPos() + Vector(0,0,2000), mask=MASK_SOLID_BRUSHONLY})
	return owner:GetStatus("manastun") or owner:GetVelocity():Length() > 150 or owner:InVehicle() or tr.HitWorld and not tr.HitSky
end

function ENT:StatusThink(owner)
	if not self.NextTick or CurTime() >= self.NextTick then
		self.NextTick = CurTime() + .25
	
		local mypos = owner:GetPos() + Vector(0, 0, 16)
		local myteam = owner:GetTeamID()
		for _, ent in pairs(ents.FindInBox(mypos + Vector(-150, -150, -100), mypos + Vector(150, 150, 2048))) do
			if ent:IsPlayer() then
				if ent:Alive() and ent:Team() ~= myteam then
					local mid = Vector(mypos.x, mypos.y, ent:GetPos().z + 200)
					local entpos = ent:NearestPoint(mid)
					if TrueVisible(mid, entpos) then
						ent:TakeSpecialDamage(1, DMGTYPE_WIND, self.Owner, self)
						ent:SetGroundEntity(NULL)
						ent:SetVelocity((mid - entpos):GetNormal() * 210)
						if ent.SetLastAttacker then
							ent:SetLastAttacker(self.Owner)
						end
					end
				end
			else
				if ent.ScriptVehicle and ent:GetTeamID() == myteam then return end

				local mid = Vector(mypos.x, mypos.y, ent:GetPos().z + 200)
				local entpos = ent:NearestPoint(mid)
				if TrueVisible(mid, entpos) then
					if ent.TakeSpecialDamage then
						ent:TakeSpecialDamage(5, DMGTYPE_WIND, self.Owner, self)
					else
						ent:TakeDamage(5, self.Owner, self)
					end

					local phys = ent:GetPhysicsObject()
					if phys:IsValid() and phys:IsMoveable() and ent:GetMoveType() == MOVETYPE_VPHYSICS then
						phys:ApplyForceOffset((mid - entpos):GetNormal() * math.Clamp(phys:GetMass() * 25, 500, 400000), (ent:NearestPoint(mid) + ent:GetPos() * 2) / 3)
					end
				end
			end
		end
	end

	self:NextThink(CurTime())
	return true
end

function ENT:StatusOnRemove(owner)
	owner:RemoveStatus("slow_noeffect")
	self.tempx1:Fire("TurnOff", "", .1)
	self.tempx2:Fire("TurnOff", "", .1)
end
