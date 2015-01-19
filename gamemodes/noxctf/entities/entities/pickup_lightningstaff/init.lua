AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/morrowind/magnus/staff/w_magnus_staff.mdl")
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetAngles(self:GetAngles() + Angle(0,0,90))
	self:SetUseType(SIMPLE_USE)
	self:DrawShadow(true)
end

function ENT:KeyValue(key, value)
	if string.lower(key) == "respawntime" then
		self.RespawnTime = tonumber(value)
		return true
	end
end

function ENT:AcceptInput(name, activator, caller)
	if name == "respawn" then
		self:SetColor(Color(255, 255, 255, 255))
		self:DrawShadow(true)
		local effectdata = EffectData()
			effectdata:SetOrigin(self:GetPos())
		util.Effect("SpawnEffect", effectdata)
		return true
	end
end

function ENT:InitiateDeath(int)
	self:Fire("kill", "", int)
end

function ENT:Use(pl)
	local c = self:GetColor()
	if c.a == 0 or not pl:Alive() then return end

	if pl:GetPlayerClassTable().Name == "Wizard" then
		if pl:HasWeapon("staff_lightning") then
			pl:PrintMessage(4, "The current game rules prevent you from picking up another one of those.")
			return
		end
		if #pl:GetWeapons() > 0 then
			local wep = pl:GetActiveWeapon()
			if wep.Droppable then
				local ent = ents.Create(wep.Droppable)
				if ent:IsValid() then
					ent:SetPos(util.TraceLine({start = pl:GetPos(), endpos = pl:GetPos() + VectorRand() * 42, filter=pl}).HitPos)
					ent.Dropped = true
					ent:Spawn()
					if wep.Mana then
						ent.Mana = wep.Mana
					end
					ent:PhysicsInit(SOLID_VPHYSICS)
					local phys = ent:GetPhysicsObject()
					if phys:IsValid() then
						phys:Wake()
						phys:SetVelocityInstantaneous(pl:GetVelocity() + VectorRand() * 100 + Vector(0, 0, 400))
						phys:AddAngleVelocity((pl:GetVelocity():Length() * VectorRand() * 90))
					end
					ent:InitiateDeath(15)
				end
			end
			pl:StripWeapons()
		end
		pl:Give("staff_lightning")
		if self.Mana then
			pl:GetWeapon("staff_lightning").Mana = self.Mana
		end
		if self.Dropped then
			self:SetColor(Color(0, 0, 0, 0))
			function self:Think()
				self:Remove()
			end
			return
		end
		self:SetColor(Color(255, 255, 255, 0))
		self:DrawShadow(false)
		if self.RespawnTime ~= -1 then
			self:Fire("respawn", "", self.RespawnTime or 20)
		end
	else
		pl:PrintMessage(4, "Your current class can not use this item.")
	end
end
