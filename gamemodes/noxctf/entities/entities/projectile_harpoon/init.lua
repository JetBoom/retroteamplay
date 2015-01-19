AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include('shared.lua')

ENT.timeToReel = 3
ENT.timeBeforeRemove = 1
ENT.hit = false
ENT.hitEntity = nil
ENT.snag = false

function ENT:Initialize()
	local owner = self:GetOwner()
	owner.harpoon = self
	owner:DeleteOnRemove(self)
	self:SetModel("models/props_junk/harpoon002a.mdl")
	self:SetModelScale(0.65,0)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_PLAYER)
	self:SetTrigger(true)

	owner:EmitSound("nox/harpoonfire.ogg")

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableDrag(false)
		phys:Wake()
	end

	self.rope = ents.Create("keyframe_rope")
	self.rope:SetPos(owner:LocalToWorld(Vector(0, 0, 40)))
	self.rope:SetEntity("startentity", owner)
	self.rope:SetEntity("endentity", self)
	self.rope:SetKeyValue("startoffset", tostring(Vector(0, 0, 40)))
	self.rope:SetKeyValue("endoffset", "0 0 0")
	self.rope:SetKeyValue("collide", 1)
	self.rope:SetKeyValue("ropematerial", "cable/rope")
	self.rope:SetKeyValue("type", 0)
	self.rope:SetKeyValue("width", 1)
	self.rope:SetParent(self)
	self.rope:Spawn()
	self.rope:Activate()
	self:DeleteOnRemove(self.rope)

	self.DeathTime = CurTime() + 10
end

function ENT:OnRemove()
	self:GetOwner().harpoon = nil
end

function ENT:PhysicsCollide(data, phys)
	self.PhysicsData = data
	self:NextThink(CurTime())
end

function ENT:Think()
	if self.DeathTime <= CurTime() then
		if self.hitEntity and self.hitEntity:IsPlayer() then
			self.hitEntity:RemoveStatus("harpoon")
		end
		if self.snag then
			self:EmitSound("nox/harpoonsnag.ogg")
		end
		self:Remove()
		return
	end
	
	if self.PhysicsData then
		if not self.hit then
			self.hit = true
			self:EmitSound("Weapon_Crowbar.Melee_HitWorld")
			self.DeathTime = CurTime() + self.timeBeforeRemove
		end
	end

	local phys = self:GetPhysicsObject()
	local owner = self:GetOwner()
	if not owner:IsValid() then return end

	local mypos = self:GetPos()
	local ownerpos = owner:NearestPoint(mypos)
	local normal = (mypos - ownerpos):GetNormal()
	local length = ownerpos:Distance(mypos)
	if not self.hit then
		if phys:IsValid() then
			phys:SetVelocityInstantaneous(self:GetForward() * 1800)
		end
		self.rope:Fire("SetLength", length * 1.1, 0)
		if length > 1000 then
			self.hit = true
			self:EmitSound("nox/harpoonsnag.ogg")
			self.DeathTime = CurTime() + self.timeBeforeRemove
		end
	elseif self.hitEntity then
		self.newlength = math.Clamp(self.maxlength * (1 - ((CurTime() - self.hitTime)/self.timeToReel)), 0, self.maxlength)
		self:SetPos(self.hitEntity:LocalToWorld(self.hitEntity:OBBCenter()))
		if 40 < length and CurTime() < self.hitTime + self.timeToReel and 0 < self.hitEntity:Health() and TrueVisible(self.hitEntity:NearestPoint(ownerpos), ownerpos) then
			self:SetAngles(Angle(0, normal:Angle().yaw, 0))
			self.rope:Fire("SetLength", self.newlength, 0)
		elseif 40 < length and CurTime() < self.hitTime + self.timeToReel * 2 and self.HitVehicle then
			self:SetAngles(Angle(0, normal:Angle().yaw, 0))
			self.rope:Fire("SetLength", self.newlength, 0)
		else
			if not self.snag then
				self.snag = true
				self.DeathTime = CurTime() + self.timeBeforeRemove
			end
		end
		
		
		if self.hitEntity:IsPlayer() then
			if not owner:GetStatus("leap") then
				if length > self.newlength then
					self.hitEntity:GiveStatus("harpoon")
					self.hitEntity:SetVelocity(-50 * normal)
				else
					self.hitEntity:RemoveStatus("harpoon")
				end
				if owner:GetVelocity():Length() > 20 and owner:GetVelocity():GetNormal():Distance(normal * -1) < 1 then
					if self.hitEntity:OnGround() then
						self.hitEntity:SetLocalVelocity(normal * owner:GetVelocity():Length() * -1 + normal * -100)
					else
						self.hitEntity:SetVelocity(normal * -25)
					end
				end
			end
		elseif self.HitVehicle then
			if self.hitEntity:GetVelocity():Length() > 300 then
				owner:SetLocalVelocity(normal * self.hitEntity:GetVelocity():Length() + normal * 150)
				owner:SetGroundEntity(NULL)
			else
				if length > self.newlength then
					owner:SetVelocity((100 * math.max(0,normal.z) + 20) * normal - owner:GetVelocity() * math.max(0,normal.z * 0.4))
				end
			end
		end
	end
	self:NextThink(CurTime())
	return true
end

function ENT:Touch(touched)
	if not self.hit and touched ~= self:GetOwner() then
		self.hit = true
		if (touched:IsPlayer() and touched:Team() ~= self:GetTeamID()) then
			self:EmitSound("nox/harpoonhit.ogg")
			self.hitEntity = touched
			self.hitEntity:DeleteOnRemove(self)
			self.maxlength = self:GetOwner():GetPos():Distance(touched:GetPos())
			self.hitTime = CurTime()
			self:SetMoveType(MOVETYPE_NONE)
			self:SetSolid(SOLID_NONE)
			self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

			touched:TakeSpecialDamage(1, DMGTYPE_PIERCING, self:GetOwner(), self)
		elseif touched.ScriptVehicle or touched:GetVehicleParent():IsValid() then
			self:EmitSound("nox/harpoonhit.ogg")
			self.hitEntity = touched
			self.HitVehicle = true
			self.hitEntity:DeleteOnRemove(self)
			self.maxlength = self:GetOwner():GetPos():Distance(touched:GetPos())
			self.hitTime = CurTime()
			self:SetMoveType(MOVETYPE_NONE)
			self:SetSolid(SOLID_NONE)
			self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		else
			self.DeathTime = CurTime() + self.timeBeforeRemove
		end 
	end
end
