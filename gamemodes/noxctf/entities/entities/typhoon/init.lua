AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
	self:EmitSound("ambient/wind/windgust_strong.wav", 85, 220)
	self:EmitSound("ambient/wind/windgust.wav")

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
		tempx:SetPos(self:GetPos())
		tempx:Spawn()
		tempx:Fire("TurnOn", "", 0)
		tempx:Fire("TurnOff", "", 5)
		tempx:Fire("kill", "", 10)
	end
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
		tempx:SetPos(self:GetPos())
		tempx:Spawn()
		tempx:Fire("TurnOn", "", 0)
		tempx:Fire("TurnOff", "", 5)
		tempx:Fire("kill", "", 10)
	end
end

function ENT:Touch(ent)
end

function ENT:Think()
	local mypos = self:GetPos()
	local myteam = self:GetTeamID()
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

	self:NextThink(CurTime() + 0.25)
	return true
end
